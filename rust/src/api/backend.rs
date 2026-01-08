use crate::comic_import;
use crate::database::{set_up_db, ComicEntity, ComicTagEntity};
use crate::frb_generated::StreamSink;
use anyhow::{anyhow, Context, Result};
use sea_orm::IntoActiveModel;
use std::fs::create_dir_all;
use std::path::Path;
use std::sync::atomic::{AtomicBool, Ordering};
use tokio::sync::OnceCell;

pub fn desktop_root() -> Result<String> {
    #[cfg(target_os = "windows")]
    {
        use anyhow::Context;
        let exe_path = std::env::current_exe()?;
        let exe_dir = exe_path.parent()
            .with_context(|| "error")?;
        let path = exe_dir.join("data");
        Ok(path.to_str().with_context(|| "error")?.to_string())
    }
    #[cfg(target_os = "macos")]
    {
        use anyhow::Context;
        let home = std::env::var_os("HOME")
            .with_context(|| "error")?
            .to_str()
            .with_context(|| "error")?
            .to_string();
        let path = Path::new(&home)
            .join("Library")
            .join("Application Support")
            .join("LCR");
        Ok(path.to_str().with_context(|| "error")?.to_string())
    }
    #[cfg(target_os = "linux")]
    {
        use anyhow::Context;
        let home = std::env::var_os("HOME")
            .with_context(|| "error")?
            .to_str()
            .with_context(|| "error")?
            .to_string();
        let path = Path::new(&home)
            .join(".data")
            .join("LCR");
        Ok(path.to_str().with_context(|| "error")?.to_string())
    }
    #[cfg(not(any(target_os = "linux", target_os = "windows", target_os = "macos")))]
    panic!("未支持的平台")
}

static INITED: AtomicBool = AtomicBool::new(false);

pub static DATABASE_DIR: OnceCell<String> = OnceCell::const_new();
pub static COMIC_DIR: OnceCell<String> = OnceCell::const_new();

pub async fn delete_comic(comic_id: String) -> Result<()> {
    comic_import::clear_comic(comic_id.as_str()).await?;
    Ok(())
}

pub async fn init_backend(application_support_path: String) -> Result<bool> {
    if INITED.fetch_or(true, Ordering::SeqCst) {
        return Ok(false);
    }
    // create  dir
    let database_dir = Path::new(&application_support_path).join("database");
    DATABASE_DIR.set(database_dir.to_string_lossy().to_string())?;
    create_dir_all(database_dir.as_path())?;
    let comic_dir = Path::new(&application_support_path).join("comic");
    COMIC_DIR.set(comic_dir.to_string_lossy().to_string())?;
    create_dir_all(comic_dir.as_path())?;
    // init database
    let database_path = database_dir.join("database.db");
    set_up_db(database_path.to_str().expect("database path is not valid")).await?;
    crate::comic_import::clear_not_imported_comic().await?;
    Ok(true)
}

pub async fn load_app_settings() -> Result<crate::AppSettings> {
    Ok(crate::database::AppSettingsEntity::find_by_id_a(0)
        .await?
        .unwrap())
}

pub async fn save_app_settings(app_settings: crate::AppSettings) -> Result<()> {
    crate::database::AppSettingsEntity::save_default(app_settings).await?;
    Ok(())
}

pub async fn import_comic(progress_sink: StreamSink<String>, path: String) -> Result<()> {
    let notifer = crate::comic_import::ImportNotifer::StreamSink(progress_sink);
    match crate::comic_import::import_comic(notifer.clone(), &path).await {
        Ok(comic) => {
            notifer.add(format!("IMPORT_FINISH_COMIC_ID:{}", comic.id))?;
        }
        Err(err) => match notifer {
            crate::comic_import::ImportNotifer::StreamSink(sk) => {
                sk.add_error(err).map_err(|e| anyhow::anyhow!(e))?;
            }
            #[cfg(test)]
            crate::comic_import::ImportNotifer::Print => (),
        },
    };
    Ok(())
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct ComicInfo {
    pub id: String,
    pub title: String,
    pub author: String,
    pub description: String,
    pub cover: String,
    pub chapter_count: i32,
    pub image_count: i32,
    pub published_date: String,
    pub import_time: i64,
    pub last_read_time: i64,
    pub last_read_chapter_id: String,
    pub last_read_chapter_title: String,
    pub last_read_page_index: i32,
    pub star: bool,
    pub status: String,
    pub tags: Vec<String>,
}

pub async fn find_comic_by_id(comic_id: &str) -> Result<Option<ComicInfo>> {
    if let Some(comic) = ComicEntity::find_by_id_a(comic_id).await? {
        let tags = ComicTagEntity::find_by_comic_id(&comic.id)
            .await?
            .iter()
            .map(|t| t.tag.clone())
            .collect();
        return Ok(Some(ComicInfo {
            id: comic.id,
            title: comic.title,
            author: comic.author,
            description: comic.description,
            cover: comic.cover,
            chapter_count: comic.chapter_count,
            image_count: comic.image_count,
            published_date: comic.published_date,
            import_time: comic.import_time,
            last_read_time: comic.last_read_time,
            last_read_chapter_id: comic.last_read_chapter_id,
            last_read_chapter_title: comic.last_read_chapter_title,
            last_read_page_index: comic.last_read_page_index,
            star: comic.star,
            status: comic.status,
            tags: tags,
        }));
    }
    Ok(None)
}

pub async fn list_ready_comic() -> Result<Vec<ComicInfo>> {
    let comics = ComicEntity::list_ready_comic().await?;
    if comics.is_empty() {
        return Ok(vec![]);
    }
    let comic_ids: Vec<String> = comics.iter().map(|c| c.id.clone()).collect();
    let tags = ComicTagEntity::find_by_comic_ids(comic_ids).await?;
    let mut result = vec![];
    for comic in comics {
        let tags = tags
            .iter()
            .filter(|t| t.comic_id == comic.id)
            .map(|t| t.tag.clone())
            .collect();
        result.push(ComicInfo {
            id: comic.id,
            title: comic.title,
            author: comic.author,
            description: comic.description,
            cover: comic.cover,
            chapter_count: comic.chapter_count,
            image_count: comic.image_count,
            published_date: comic.published_date,
            import_time: comic.import_time,
            last_read_time: comic.last_read_time,
            last_read_chapter_id: comic.last_read_chapter_id,
            last_read_chapter_title: comic.last_read_chapter_title,
            last_read_page_index: comic.last_read_page_index,
            star: comic.star,
            status: comic.status,
            tags: tags,
        });
    }
    Ok(result)
}

pub async fn update_comic(comic_info: ComicInfo) -> Result<()> {
    let mut comic: crate::database::comic::ActiveModel = ComicEntity::find_by_id_a(&comic_info.id)
        .await?
        .ok_or_else(|| anyhow::anyhow!("Comic not found"))?
        .into_active_model();
    comic.title = sea_orm::Set(comic_info.title);
    comic.author = sea_orm::Set(comic_info.author);
    comic.description = sea_orm::Set(comic_info.description);
    comic.cover = sea_orm::Set(comic_info.cover);
    comic.chapter_count = sea_orm::Set(comic_info.chapter_count);
    comic.image_count = sea_orm::Set(comic_info.image_count);
    comic.published_date = sea_orm::Set(comic_info.published_date);
    comic.last_read_time = sea_orm::Set(comic_info.last_read_time);
    comic.last_read_chapter_id = sea_orm::Set(comic_info.last_read_chapter_id);
    comic.last_read_chapter_title = sea_orm::Set(comic_info.last_read_chapter_title);
    comic.last_read_page_index = sea_orm::Set(comic_info.last_read_page_index);
    comic.star = sea_orm::Set(comic_info.star);
    comic.status = sea_orm::Set(comic_info.status);
    ComicEntity::update_active_model(comic).await?;
    // update tags
    ComicTagEntity::update_comic_tags(&comic_info.id, comic_info.tags).await?;
    Ok(())
}

pub async fn update_comic_cover(comic_id: String, source: String) -> Result<()> {
    let buff = tokio::fs::read(source).await?;
    let format = image::guess_format(&buff)?.extensions_str()[0];
    let file_name = format!("{}.{}", "cover", format);
    let comic_folder = Path::new(COMIC_DIR.get().unwrap()).join(comic_id.as_str());
    let comic_cover_path = comic_folder.join(file_name.as_str());
    tokio::fs::write(comic_cover_path.as_path(), buff).await?;
    ComicEntity::update_cover(comic_id.as_str(), file_name.as_str()).await?;
    Ok(())
}

pub async fn modify_comic_star(comic_id: &str, star: bool) -> Result<()> {
    ComicEntity::modify_star(comic_id, star).await?;
    Ok(())
}

pub async fn reader_settings(comic_id: String) -> Result<Option<crate::ReaderSettings>> {
    if comic_id.is_empty() {
        return Ok(crate::database::ReaderSettingsEntity::find_default().await?);
    }
    Ok(crate::database::ReaderSettingsEntity::find_by_comic_id(&comic_id).await?)
}

pub async fn chapter_list(comic_id: &str) -> Result<Vec<crate::ComicChapter>> {
    Ok(crate::database::ComicChapterEntity::find_by_comic_id(comic_id).await?)
}

pub async fn image_list(chapter_id: &str) -> Result<Vec<crate::ComicImage>> {
    Ok(crate::database::ComicImageEntity::find_by_chapter_id(chapter_id).await?)
}

pub async fn update_comic_read(
    comic_id: String,
    chapter_id: String,
    chapter_title: String,
    page_index: i32,
) -> Result<()> {
    let mut comic: crate::database::comic::ActiveModel = ComicEntity::find_by_id_a(&comic_id)
        .await?
        .ok_or_else(|| anyhow::anyhow!("Comic not found"))?
        .into_active_model();
    comic.last_read_time = sea_orm::Set(chrono::Local::now().timestamp());
    comic.last_read_chapter_id = sea_orm::Set(chapter_id);
    comic.last_read_chapter_title = sea_orm::Set(chapter_title);
    comic.last_read_page_index = sea_orm::Set(page_index);
    ComicEntity::update_active_model(comic).await?;
    Ok(())
}

pub async fn copy_global_reader_settings_to_comic(comic_id: String) -> Result<()> {
    let mut global_settings = crate::database::ReaderSettingsEntity::find_default()
        .await?
        .with_context(|| anyhow!(""))?;
    global_settings.comic_id = comic_id;
    global_settings.settings_type = "COMIC".to_string();
    crate::database::ReaderSettingsEntity::save_or_update_by_comic_id(global_settings).await?;
    Ok(())
}

pub async fn delete_comic_reader_settings(comic_id: String) -> Result<()> {
    crate::database::ReaderSettingsEntity::delete_by_comic_id(comic_id.as_str()).await?;
    Ok(())
}

pub async fn update_comic_reader_settings(
    comic_id: String,
    settings: crate::ReaderSettings,
) -> Result<()> {
    let mut updated_settings = settings;
    updated_settings.comic_id = comic_id.clone();
    updated_settings.settings_type = "COMIC".to_string();
    crate::database::ReaderSettingsEntity::save_or_update_by_comic_id(updated_settings).await?;
    Ok(())
}

pub async fn update_global_reader_settings(settings: crate::ReaderSettings) -> Result<()> {
    let mut updated_settings = settings;
    updated_settings.id = 0;
    updated_settings.settings_type = "DEFAULT".to_string();
    updated_settings.comic_id = "".to_string();
    updated_settings.template_name = "".to_string();
    crate::database::ReaderSettingsEntity::save_or_update_by_comic_id(updated_settings).await?;
    Ok(())
}
