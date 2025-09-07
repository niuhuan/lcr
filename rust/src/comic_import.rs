use crate::database::{self, ComicImageEntity};
use anyhow::{anyhow, Context};
use sea_orm::{ColumnTrait, EntityTrait, IntoActiveModel, QueryFilter};
use std::{collections::HashMap, path::Path, vec};
use tokio::{fs::File, io::BufReader};
use tokio_util::compat::Compat;

use crate::{
    api::backend::COMIC_DIR,
    database::{comic_image, ComicChapterEntity, ComicEntity},
    frb_generated::StreamSink,
};

#[derive(Clone)]
pub enum ImportNotifer {
    StreamSink(StreamSink<String>),
    #[cfg(test)]
    Print,
}

impl ImportNotifer {
    pub fn add(&self, message: String) -> anyhow::Result<()> {
        match self {
            ImportNotifer::StreamSink(sink) => {
                sink.add(message).map_err(|e| anyhow::anyhow!(e))?;
                Ok(())
            }
            #[cfg(test)]
            ImportNotifer::Print => {
                println!("{}", message);
                Ok(())
            }
        }
    }
}

pub(crate) async fn import_comic(
    progress_sink: ImportNotifer,
    path: &str,
) -> anyhow::Result<crate::Comic> {
    if path.is_empty() {
        return Err(anyhow::anyhow!("path is empty"));
    }
    // is folder
    if std::path::Path::new(path).is_dir() {
        return import_folder(progress_sink, path).await;
    }
    // got extension
    let extension = std::path::Path::new(path)
        .extension()
        .and_then(|s| s.to_str())
        .unwrap_or("")
        .to_lowercase();
    let comic = match extension.as_str() {
        "cbz" | "zip" => import_zip(progress_sink, path).await?,
        "epub" => import_epub(progress_sink, path).await?,
        _ => {
            return Err(anyhow::anyhow!("unsupported file type: {}", extension));
        }
    };
    Ok(comic)
}

#[async_trait::async_trait]
trait ResourceReader: Sync + Send {
    async fn read_resource(&mut self, path: &str) -> anyhow::Result<(Vec<String>, Vec<String>)>;
    async fn dump_resource(&mut self, path: &str) -> anyhow::Result<Vec<u8>>;
}

struct FolderResourceReader(String);

#[async_trait::async_trait]
impl ResourceReader for FolderResourceReader {
    async fn read_resource(&mut self, path: &str) -> anyhow::Result<(Vec<String>, Vec<String>)> {
        let path = if path.is_empty() {
            Path::new(&self.0).to_path_buf()
        } else {
            Path::new(&self.0).join(path)
        };
        let mut entries = tokio::fs::read_dir(path.into_os_string()).await?;
        let mut files = Vec::new();
        let mut folders = Vec::new();
        while let Some(entry) = entries.next_entry().await? {
            let path = entry.path();
            let filename = path
                .file_name()
                .ok_or(anyhow!(""))?
                .to_string_lossy()
                .to_string();
            if path.is_file() {
                files.push(filename);
            } else {
                let mut file = filename;
                file.push_str("/");
                folders.push(file);
            }
        }
        files.sort();
        folders.sort();
        Ok((files, folders))
    }

    async fn dump_resource(&mut self, path: &str) -> anyhow::Result<Vec<u8>> {
        let source = Path::new(self.0.as_str()).join(path);
        let data = tokio::fs::read(source).await?;
        Ok(data)
    }
}

struct ZipResourceReader(
    async_zip::base::read::seek::ZipFileReader<Compat<BufReader<File>>>,
    HashMap<String, usize>,
);

#[async_trait::async_trait]
impl ResourceReader for ZipResourceReader {
    async fn read_resource(&mut self, path: &str) -> anyhow::Result<(Vec<String>, Vec<String>)> {
        let prefix = if path.is_empty() {
            "".to_owned()
        } else {
            format!("{path}/")
        };
        let prefix = prefix.as_str();
        let mut files = Vec::new();
        let mut folders = Vec::new();
        for (name, _) in &self.1 {
            if prefix.is_empty() {
                if name.ends_with("/") {
                    if name[..name.len() - 1].contains('/') {
                        continue;
                    }
                    folders.push(name.to_string());
                } else {
                    if name.contains('/') {
                        continue;
                    }
                    files.push(name.to_string());
                }
            } else {
                if name.starts_with(prefix) && !name.eq(prefix) {
                    let name = name[prefix.len()..].to_string();
                    if name.ends_with("/") {
                        folders.push(name);
                    } else {
                        files.push(name);
                    }
                }
            }
        }
        files.sort();
        Ok((files, folders))
    }

    async fn dump_resource(&mut self, path: &str) -> anyhow::Result<Vec<u8>> {
        if let Some(index) = self.1.get(path) {
            let mut reader = self.0.reader_with_entry(*index).await?;
            let mut data = vec![];
            reader.read_to_end_checked(&mut data).await?;
            return Ok(data);
        }
        Err(anyhow::anyhow!("file not found in zip: {}", path))
    }
}

async fn import_folder(progress_sink: ImportNotifer, path: &str) -> anyhow::Result<crate::Comic> {
    import_reources(
        progress_sink,
        &mut FolderResourceReader(path.to_string()),
        path,
    )
    .await
}

async fn import_zip(progress_sink: ImportNotifer, path: &str) -> anyhow::Result<crate::Comic> {
    let file = tokio::fs::File::open(path).await?;
    let reader = tokio::io::BufReader::new(file);
    let zip_file_reader = async_zip::tokio::read::seek::ZipFileReader::with_tokio(reader).await?;
    let entries = zip_file_reader.file().entries();
    let mut map = HashMap::new();
    for index in 0..entries.len() {
        let entry = entries.get(index).unwrap();
        let name = entry.filename();
        let name = String::from_utf8(name.as_bytes().to_vec())?;
        map.insert(name, index);
    }
    import_reources(
        progress_sink,
        &mut ZipResourceReader(zip_file_reader, map),
        path,
    )
    .await
}

async fn import_reources(
    progress_sink: ImportNotifer,
    reader: &mut impl ResourceReader,
    path: &str,
) -> anyhow::Result<crate::Comic> {
    let comic_name = Path::new(path)
        .file_stem()
        .and_then(|s| s.to_str())
        .unwrap_or("unknown");
    let comic_id = ComicEntity::create_comic(comic_name).await?;
    let comic_folder = Path::new(COMIC_DIR.get().unwrap()).join(comic_id.as_str());
    let mut next_chapter_index = 1;
    let result = loop_into_comic(
        &progress_sink,
        reader,
        comic_id.as_str(),
        comic_folder.as_path(),
        "",
        &mut next_chapter_index,
    )
    .await;
    match result {
        Ok(_) => {
            let comic = ComicEntity::find_by_id_a(comic_id.as_str()).await?.unwrap();
            let chapters = ComicChapterEntity::find_by_comic_id(comic_id.as_str()).await?;
            let chapter_count = chapters.len() as i32;
            let image_count = chapters
                .iter()
                .map(|c| c.image_count)
                .reduce(|a, b| a + b)
                .unwrap_or_default();
            if comic.cover.is_empty() {
                if let Some(first_chapter) = chapters.first() {
                    if let Some(first_image) =
                        ComicImageEntity::find_by_chapter_id(&first_chapter.id)
                            .await?
                            .first()
                    {
                        ComicEntity::update_cover(comic_id.as_str(), &first_image.path).await?;
                    }
                }
            }
            let _ = ComicEntity::set_success(comic_id.as_str(), chapter_count, image_count).await;
            let comic = ComicEntity::find_by_id_a(comic_id.as_str()).await?.unwrap();
            Ok(comic)
        }
        Err(err) => {
            let _ = clear_comic(comic_id.as_str()).await;
            Err(err)
        }
    }
}

pub async fn clear_comic(comic_id: &str) -> anyhow::Result<()> {
    // 删除漫画文件夹
    let comic_folder =
        std::path::Path::new(crate::api::backend::COMIC_DIR.get().unwrap()).join(comic_id);
    let _ = tokio::fs::remove_dir_all(&comic_folder).await;
    // 删除相关标签
    database::comic_tag::Entity::delete_by_comic_id(comic_id).await?;
    // 删除相关书签
    database::comic_bookmark::Entity::delete_by_comic_id(comic_id).await?;
    // 删除相关设置
    database::reader_settings::Entity::delete_by_comic_id(comic_id).await?;
    // 删除相关图片
    database::comic_image::Entity::delete_by_comic_id(comic_id).await?;
    // 删除相关章节
    database::comic_chapter::Entity::delete_by_comic_id(comic_id).await?;
    // 删除数据库中的相关记录
    ComicEntity::delete_by_id_a(comic_id).await?;
    Ok(())
}

pub async fn clear_not_imported_comic() -> anyhow::Result<()> {
    let comics = ComicEntity::find()
        .filter(database::comic::Column::Status.eq("IMPORTING"))
        .all(crate::database::DB.get().unwrap())
        .await?;
    for comic in comics {
        let _ = clear_comic(&comic.id).await;
    }
    Ok(())
}

async fn loop_into_comic(
    progress_sink: &ImportNotifer,
    reader: &mut impl ResourceReader,
    comic_id: &str,
    comic_folder: &Path,
    folder: &str,
    index_in_comic: &mut i32,
) -> anyhow::Result<()> {
    let mut created_folder = vec![];
    let (files, folders) = reader.read_resource(folder).await?;
    let files = files
        .iter()
        .filter(|f| {
            let ext = Path::new(f)
                .extension()
                .and_then(|s| s.to_str())
                .unwrap_or("")
                .to_lowercase();
            matches!(
                ext.as_str(),
                "jpg" | "jpeg" | "png" | "webp" | "gif" | "bmp"
            )
        })
        .collect::<Vec<_>>();
    if files.len() > 0 {
        let chapter_id = ComicChapterEntity::create_chapter(
            comic_id,
            Path::new(folder).file_name().and_then(|s| s.to_str()),
            *index_in_comic,
        )
        .await?;
        *index_in_comic = *index_in_comic + 1;
        let mut index_in_chapter = 1;
        for file in files {
            progress_sink.add(format!("Importing : {folder}{file}"))?;
            let file_source_path = format!("{folder}{file}");
            let file_target_path = comic_folder.join(&file_source_path);
            let parent = file_target_path.parent();
            if let Some(parent) = parent {
                if !created_folder.contains(&parent.to_string_lossy().to_string()) {
                    if !parent.exists() {
                        tokio::fs::create_dir_all(parent).await?;
                    }
                    created_folder.push(parent.to_string_lossy().to_string());
                }
            }
            let data = reader.dump_resource(file_source_path.as_str()).await?;
            let image = if let Ok(image) = image::load_from_memory(&data) {
                tokio::fs::write(&file_target_path, &data).await?;
                let format = image::guess_format(&data)
                    .unwrap_or(image::ImageFormat::Png)
                    .extensions_str()[0]
                    .to_owned();
                comic_image::Model {
                    id: uuid::Uuid::new_v4().to_string(),
                    comic_id: comic_id.to_string(),
                    chapter_id: chapter_id.clone(),
                    index_in_chapter,
                    path: file_source_path,
                    width: image.width() as i32,
                    height: image.height() as i32,
                    format: format,
                    status: "READY".to_string(),
                }
            } else {
                comic_image::Model {
                    id: uuid::Uuid::new_v4().to_string(),
                    comic_id: comic_id.to_string(),
                    chapter_id: chapter_id.clone(),
                    index_in_chapter,
                    path: file_source_path,
                    format: "UNKNOWN".to_string(),
                    status: "ERROR".to_string(),
                    ..Default::default()
                }
            };
            index_in_chapter += 1;
            comic_image::Entity::insert(image.into_active_model())
                .exec(crate::database::DB.get().unwrap())
                .await?;
        }
        let _ = ComicChapterEntity::update_image_count(&chapter_id, index_in_chapter - 1).await;
    }
    if folders.len() > 0 {
        for sub_folder in folders {
            Box::pin(loop_into_comic(
                progress_sink,
                reader,
                comic_id,
                comic_folder,
                format!("{folder}{sub_folder}").as_str(),
                index_in_comic,
            ))
            .await?;
        }
    }
    Ok(())
}

async fn import_epub(progress_sink: ImportNotifer, path: &str) -> anyhow::Result<crate::Comic> {
    // 以zip方式打开epub
    let file = tokio::fs::File::open(path).await?;
    let reader = tokio::io::BufReader::new(file);
    let mut zip_file_reader =
        async_zip::tokio::read::seek::ZipFileReader::with_tokio(reader).await?;
    let entries = zip_file_reader.file().entries();
    let mut map = HashMap::new();
    for index in 0..entries.len() {
        let entry = entries.get(index).unwrap();
        let name = entry.filename();
        let name = String::from_utf8(name.as_bytes().to_vec())?;
        map.insert(name, index);
    }
    // 寻找 content.opf
    // let mut identifier: String = "unknown".to_string();
    let mut title: String = "unknown".to_string();
    let mut author: String = "".to_string();
    let mut cover: String = "".to_string();
    let mut resource_href_id_map = HashMap::new();
    let mut resource_id_href_map = HashMap::new();
    let mut page_id_list = vec![];
    let mut source_href_chapter_title_map = HashMap::new();
    //
    let content_opf_idx = map
        .get("content.opf")
        .with_context(|| anyhow!("content.opf not found"))?;
    let mut content_opf_reader = zip_file_reader.reader_with_entry(*content_opf_idx).await?;
    let mut content_opf_data = vec![];
    content_opf_reader
        .read_to_end_checked(&mut content_opf_data)
        .await?;
    let content_opf = String::from_utf8(content_opf_data)?;
    let doc = roxmltree::Document::parse(&content_opf)?;
    let children = doc.root_element().children();
    for ele in children {
        if ele.tag_name().name().eq("metadata") {
            for meta in ele.children() {
                if meta.tag_name().name().eq("title") {
                    title = meta.text().unwrap_or("unknown").to_string();
                    println!("title: {}", title);
                } else if meta.tag_name().name().eq("creator") {
                    let this_author = meta.text().unwrap_or("unknown");
                    if !author.is_empty() {
                        author.push_str(", ");
                    }
                    author.push_str(this_author);
                } else if meta.tag_name().name().eq("identifier") {
                    // identifier = meta.text().unwrap_or("unknown").to_string();
                } else if meta.tag_name().name().eq("meta") {
                    let name = meta.attribute("name").unwrap_or("");
                    if name.eq("cover") {
                        cover = meta.attribute("content").unwrap_or("").to_string();
                    }
                }
            }
        } else if ele.tag_name().name().eq("manifest") {
            for item in ele.children() {
                if item.tag_name().name().eq("item") {
                    let id = item.attribute("id").unwrap_or("");
                    let href = item.attribute("href").unwrap_or("");
                    // let media_type = item.attribute("media-type").unwrap_or("");
                    if !id.is_empty() && !href.is_empty() {
                        resource_href_id_map.insert(href.to_string(), id.to_string());
                        resource_id_href_map.insert(id.to_string(), href.to_string());
                    }
                }
            }
        } else if ele.tag_name().name().eq("spine") {
            for itemref in ele.children() {
                if itemref.tag_name().name().eq("itemref") {
                    let idref = itemref.attribute("idref").unwrap_or("");
                    if !idref.is_empty() {
                        page_id_list.push(idref.to_string());
                    }
                }
            }
        }
    }
    // let id_regex = regex::Regex::new(r"[^0-9a-zA-Z\-_]").unwrap();
    // if identifier.is_empty() || identifier.eq("unknown") || !id_regex.is_match(&identifier) {
    let identifier = uuid::Uuid::new_v4().to_string();
    // }
    if let Some(toc_ncx_idx) = map.get("toc.ncx") {
        let mut toc_ncx_reader = zip_file_reader.reader_with_entry(*toc_ncx_idx).await?;
        let mut toc_ncx_data = vec![];
        toc_ncx_reader
            .read_to_end_checked(&mut toc_ncx_data)
            .await?;
        let toc_ncx = String::from_utf8(toc_ncx_data)?;
        let doc = roxmltree::Document::parse(&toc_ncx)?;
        let children = doc.root_element().children();
        for ele in children {
            if ele.tag_name().name().eq("navMap") {
                for nav_point in ele.children() {
                    if nav_point.tag_name().name().eq("navPoint") {
                        let mut nav_label = "unknown".to_string();
                        let mut content_src = "unknown".to_string();
                        for nav_point_child in nav_point.children() {
                            if nav_point_child.tag_name().name().eq("navLabel") {
                                for label in nav_point_child.children() {
                                    if label.tag_name().name().eq("text") {
                                        nav_label = label.text().unwrap_or("unknown").to_string();
                                    }
                                }
                            } else if nav_point_child.tag_name().name().eq("content") {
                                content_src = nav_point_child
                                    .attribute("src")
                                    .unwrap_or("unknown")
                                    .to_string();
                            } else if nav_point_child.tag_name().name().eq("navPoint") {
                                // sub navPoint
                                let mut nav_label = "unknown".to_string();
                                let mut content_src = "unknown".to_string();
                                for nav_point_child in nav_point_child.children() {
                                    if nav_point_child.tag_name().name().eq("navLabel") {
                                        for label in nav_point_child.children() {
                                            if label.tag_name().name().eq("text") {
                                                nav_label =
                                                    label.text().unwrap_or("unknown").to_string();
                                            }
                                        }
                                    } else if nav_point_child.tag_name().name().eq("content") {
                                        content_src = nav_point_child
                                            .attribute("src")
                                            .unwrap_or("unknown")
                                            .to_string();
                                    }
                                }
                                if content_src.contains("#") {
                                    content_src = content_src
                                        .split('#')
                                        .next()
                                        .unwrap_or("unknown")
                                        .to_string();
                                }
                                if !nav_label.is_empty()
                                    && !nav_label.eq("unknown")
                                    && !content_src.is_empty()
                                    && !content_src.eq("unknown")
                                {
                                    source_href_chapter_title_map
                                        .insert(content_src.clone(), nav_label.clone());
                                }
                                println!("  navPoint: {} -> {}", nav_label, content_src);
                            }
                        }
                        if content_src.contains("#") {
                            content_src = content_src
                                .split('#')
                                .next()
                                .unwrap_or("unknown")
                                .to_string();
                        }
                        if !nav_label.is_empty()
                            && !nav_label.eq("unknown")
                            && !content_src.is_empty()
                            && !content_src.eq("unknown")
                        {
                            source_href_chapter_title_map
                                .insert(content_src.clone(), nav_label.clone());
                        }
                        println!("navPoint: {} -> {}", nav_label, content_src);
                    }
                }
            }
        }
    } else {
        println!("toc.ncx not found");
    }
    println!("map: {:?}", map);
    match import_epub2(
        &progress_sink,
        identifier.clone(),
        title,
        author,
        cover,
        resource_href_id_map,
        resource_id_href_map,
        page_id_list,
        source_href_chapter_title_map,
        ZipResourceReader(zip_file_reader, map),
    )
    .await
    {
        Ok(comic) => {
            let chapters = ComicChapterEntity::find_by_comic_id(comic.id.as_str()).await?;
            let chapter_count = chapters.len() as i32;
            let image_count = chapters
                .iter()
                .map(|c| c.image_count)
                .reduce(|a, b| a + b)
                .unwrap_or_default();
            if comic.cover.is_empty() {
                if let Some(first_chapter) = chapters.first() {
                    if let Some(first_image) =
                        ComicImageEntity::find_by_chapter_id(&first_chapter.id)
                            .await?
                            .first()
                    {
                        ComicEntity::update_cover(comic.id.as_str(), &first_image.path).await?;
                    }
                }
            }
            let _ = ComicEntity::set_success(comic.id.as_str(), chapter_count, image_count).await;
            let comic = ComicEntity::find_by_id_a(comic.id.as_str()).await?.unwrap();
            Ok(comic)
        }
        Err(err) => {
            let _ = clear_comic(identifier.as_str()).await;
            Err(err)
        }
    }
}

async fn import_epub2(
    progress_sink: &ImportNotifer,
    identifier: String,
    title: String,
    author: String,
    cover: String,
    resource_href_id_map: HashMap<String, String>,
    resource_id_href_map: HashMap<String, String>,
    page_id_list: Vec<String>,
    source_href_chapter_title_map: HashMap<String, String>,
    mut mutreader: ZipResourceReader,
) -> anyhow::Result<crate::Comic> {
    let mut adding_chapter_title = "Root".to_string();
    let mut image_hrefs: Vec<String> = vec![];
    let mut chapters: Vec<(String, Vec<String>)> = vec![];
    for page_id in page_id_list {
        progress_sink.add(page_id.clone())?;
        if let Some(href) = resource_id_href_map.get(&page_id) {
            if let Some(chapter_title) = source_href_chapter_title_map.get(href) {
                // push old chapter
                if image_hrefs.len() > 0 {
                    chapters.push((adding_chapter_title.to_string(), image_hrefs));
                    image_hrefs = vec![];
                }
                // new chapter
                adding_chapter_title = chapter_title.clone();
            }
            //
            if let Ok(data) = mutreader.dump_resource(href).await {
                let html = scraper::Html::parse_document(std::str::from_utf8(&data)?);
                html.select(&scraper::Selector::parse("img").unwrap())
                    .for_each(|img| {
                        if let Some(src) = img.value().attr("src") {
                            let mut src = src.to_string();
                            if src.starts_with("./") {
                                let path = Path::new(href);
                                let parent = path.parent().unwrap_or(Path::new(""));
                                src = parent
                                    .join(src[2..].to_string())
                                    .to_string_lossy()
                                    .to_string();
                            } else if src.starts_with("../") {
                                let path = Path::new(href);
                                let parent = path.parent().unwrap_or(Path::new(""));
                                let parent = parent.parent().unwrap_or(Path::new(""));
                                src = parent
                                    .join(src[3..].to_string())
                                    .to_string_lossy()
                                    .to_string();
                            }
                            if resource_href_id_map.contains_key(&src) {
                                image_hrefs.push(src);
                            }
                        }
                    });
            }
        }
    }
    // push last chapter
    if image_hrefs.len() > 0 {
        chapters.push((adding_chapter_title, image_hrefs));
    }
    //
    let comic_id =
        ComicEntity::create_comic2(identifier.as_str(), title.as_str(), author.as_str()).await?;
    let comic_folder = Path::new(COMIC_DIR.get().unwrap()).join(comic_id.as_str());
    let mut next_chapter_index = 1;
    let mut created_folder = vec![];
    for (chapter_title, image_hrefs) in chapters {
        let chapter_id = ComicChapterEntity::create_chapter(
            comic_id.as_str(),
            Some(chapter_title.as_str()),
            next_chapter_index,
        )
        .await?;
        next_chapter_index += 1;
        let mut index_in_chapter = 1;
        for href in image_hrefs {
            progress_sink.add(format!("Importing : {href}"))?;
            let file_target_path = comic_folder.join(&href);
            let parent = file_target_path.parent();
            if let Some(parent) = parent {
                if !created_folder.contains(&parent.to_string_lossy().to_string()) {
                    if !parent.exists() {
                        tokio::fs::create_dir_all(parent).await?;
                    }
                    created_folder.push(parent.to_string_lossy().to_string());
                }
            }
            let image = if let Ok(data) = mutreader.dump_resource(href.as_str()).await {
                if let Ok(image) = image::load_from_memory(&data) {
                    tokio::fs::write(&file_target_path, &data).await?;
                    let format = image::guess_format(&data)
                        .unwrap_or(image::ImageFormat::Png)
                        .extensions_str()[0]
                        .to_owned();
                    comic_image::Model {
                        id: uuid::Uuid::new_v4().to_string(),
                        comic_id: comic_id.to_string(),
                        chapter_id: chapter_id.clone(),
                        index_in_chapter,
                        path: href,
                        width: image.width() as i32,
                        height: image.height() as i32,
                        format: format,
                        status: "READY".to_string(),
                    }
                } else {
                    comic_image::Model {
                        id: uuid::Uuid::new_v4().to_string(),
                        comic_id: comic_id.to_string(),
                        chapter_id: chapter_id.clone(),
                        index_in_chapter,
                        path: href,
                        format: "UNKNOWN".to_string(),
                        status: "ERROR".to_string(),
                        ..Default::default()
                    }
                }
            } else {
                comic_image::Model {
                    id: uuid::Uuid::new_v4().to_string(),
                    comic_id: comic_id.to_string(),
                    chapter_id: chapter_id.clone(),
                    index_in_chapter,
                    path: href,
                    format: "UNKNOWN".to_string(),
                    status: "ERROR".to_string(),
                    ..Default::default()
                }
            };
            index_in_chapter += 1;
            comic_image::Entity::insert(image.into_active_model())
                .exec(crate::database::DB.get().unwrap())
                .await?;
        }
        let _ = ComicChapterEntity::update_image_count(&chapter_id, index_in_chapter - 1).await;
    }
    if !cover.is_empty() {
        if let Some(href) = resource_id_href_map.get(&cover) {
            if let Ok(data) = mutreader.dump_resource(href).await {
                if let Ok(_) = image::load_from_memory(&data) {
                    let file_target_path = comic_folder.join(&href);
                    let parent = file_target_path.parent();
                    if let Some(parent) = parent {
                        if !created_folder.contains(&parent.to_string_lossy().to_string()) {
                            if !parent.exists() {
                                tokio::fs::create_dir_all(parent).await?;
                            }
                            created_folder.push(parent.to_string_lossy().to_string());
                        }
                    }
                    tokio::fs::write(&file_target_path, &data).await?;
                    ComicEntity::update_cover(comic_id.as_str(), &href.as_str()).await?;
                }
            }
        }
    }
    let comic = ComicEntity::find_by_id_a(comic_id.as_str()).await?.unwrap();
    Ok(comic)
}

#[cfg(test)]
mod tests {

    #[tokio::test]
    async fn remove_database() {
        let home = std::env::var_os("HOME")
            .unwrap()
            .to_str()
            .unwrap()
            .to_string();
        let path = format!(
            "{home}/Library/Containers/opensource.lcr/Data/Library/Application Support/LCR"
        );
        tokio::fs::remove_dir_all(path).await.unwrap();
    }

    #[tokio::test]
    async fn test_import_comic() {
        let home = std::env::var_os("HOME")
            .unwrap()
            .to_str()
            .unwrap()
            .to_string();
        crate::api::backend::init_backend(format!(
            "{home}/Library/Containers/opensource.lcr/Data/Library/Application Support/LCR"
        ))
        .await
        .unwrap();
        let path = format!("{home}/Downloads/test_comic/test_comic.zip");
        super::import_comic(super::ImportNotifer::Print, path.as_str())
            .await
            .unwrap();
    }

    #[tokio::test]
    async fn test_import_epub() {
        let home = std::env::var_os("HOME")
            .unwrap()
            .to_str()
            .unwrap()
            .to_string();
        crate::api::backend::init_backend(format!(
            "{home}/Library/Containers/opensource.lcr/Data/Library/Application Support/LCR"
        ))
        .await
        .unwrap();
        let path = format!("{home}/Downloads/Telegram Desktop/哆啦A梦珍藏版_第一部.epub");
        let _ = super::import_epub(super::ImportNotifer::Print, path.as_str()).await;
    }
}
