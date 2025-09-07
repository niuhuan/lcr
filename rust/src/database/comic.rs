use sea_orm::entity::prelude::*;
use sea_orm::{
    ActiveModelBehavior, ColumnTrait, EntityTrait, IntoActiveModel, QueryFilter, QueryOrder, Set,
};

#[derive(
    Clone, Debug, PartialEq, Eq, DeriveEntityModel, Default, serde::Serialize, serde::Deserialize,
)]
#[sea_orm(table_name = "comic")]
#[flutter_rust_bridge::frb(dart_metadata=("freezed"), mirror(Comic))]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = false)]
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
}

pub type Comic = Model;

#[derive(Copy, Clone, Debug, EnumIter, DeriveRelation)]
pub enum Relation {
    #[sea_orm(has_many = "super::comic_chapter::Entity")]
    ComicChapter,
    #[sea_orm(has_many = "super::comic_image::Entity")]
    ComicImage,
    #[sea_orm(has_many = "super::comic_tag::Entity")]
    ComicTag,
    #[sea_orm(has_many = "super::comic_bookmark::Entity")]
    ComicBookmark,
}

impl Related<super::comic_chapter::Entity> for Entity {
    fn to() -> RelationDef {
        Relation::ComicChapter.def()
    }
}
impl Related<super::comic_image::Entity> for Entity {
    fn to() -> RelationDef {
        Relation::ComicImage.def()
    }
}
impl Related<super::comic_tag::Entity> for Entity {
    fn to() -> RelationDef {
        Relation::ComicTag.def()
    }
}
impl Related<super::comic_bookmark::Entity> for Entity {
    fn to() -> RelationDef {
        Relation::ComicBookmark.def()
    }
}

impl ActiveModelBehavior for ActiveModel {}

impl Entity {
    pub async fn list_ready_comic() -> anyhow::Result<Vec<Model>> {
        Ok(Self::find()
            .filter(Column::Status.eq("READY".to_string()))
            .order_by_desc(Column::LastReadTime)
            .all(super::DB.get().unwrap())
            .await?)
    }

    pub async fn create_comic(comic_name: &str) -> anyhow::Result<String> {
        let id = uuid::Uuid::new_v4().to_string();
        let now = chrono::Utc::now().timestamp_millis() as i64;
        let comic = Model {
            id: id.clone(),
            title: comic_name.to_string(),
            status: "IMPORTING".to_string(),
            last_read_time: now,
            import_time: now,
            ..Default::default()
        };
        Self::insert(comic.into_active_model())
            .exec(super::DB.get().unwrap())
            .await?;
        Ok(id)
    }

    pub async fn create_comic2(
        identifier: &str,
        title: &str,
        author: &str,
    ) -> anyhow::Result<String> {
        let id = identifier.to_string();
        let now = chrono::Utc::now().timestamp_millis() as i64;
        let comic = Model {
            id: id.clone(),
            title: title.to_string(),
            author: author.to_string(),
            status: "IMPORTING".to_string(),
            last_read_time: now,
            import_time: now,
            ..Default::default()
        };
        Self::insert(comic.into_active_model())
            .exec(super::DB.get().unwrap())
            .await?;
        Ok(id)
    }

    pub async fn set_success(
        comic_id: &str,
        chapter_count: i32,
        image_count: i32,
    ) -> anyhow::Result<()> {
        let db = super::DB.get().unwrap();
        let comic = Self::find_by_id(comic_id).one(db).await?;
        if let Some(comic) = comic {
            let mut comic: ActiveModel = comic.into();
            comic.status = sea_orm::Set("READY".to_string());
            comic.chapter_count = sea_orm::Set(chapter_count);
            comic.image_count = sea_orm::Set(image_count);
            Self::update(comic).exec(db).await?;
        }
        Ok(())
    }

    pub async fn delete_by_id_a(comic_id: &str) -> anyhow::Result<()> {
        Self::delete_by_id(comic_id)
            .exec(super::DB.get().unwrap())
            .await?;
        Ok(())
    }

    pub async fn find_by_id_a(comic_id: &str) -> anyhow::Result<Option<Model>> {
        Ok(Self::find_by_id(comic_id)
            .one(super::DB.get().unwrap())
            .await?)
    }

    pub async fn update_cover(comic_id: &str, cover: &str) -> anyhow::Result<()> {
        let mut comic: ActiveModel = Self::find_by_id(comic_id)
            .one(super::DB.get().unwrap())
            .await?
            .ok_or_else(|| anyhow::anyhow!("Comic not found"))?
            .into_active_model();
        comic.cover = Set(cover.to_string());
        comic.update(super::DB.get().unwrap()).await?;
        Ok(())
    }

    pub async fn update_active_model(comic: ActiveModel) -> anyhow::Result<()> {
        comic.update(super::DB.get().unwrap()).await?;
        Ok(())
    }

    pub async fn modify_star(comic_id: &str, star: bool) -> anyhow::Result<()> {
        let mut comic: ActiveModel = Self::find_by_id(comic_id)
            .one(super::DB.get().unwrap())
            .await?
            .ok_or_else(|| anyhow::anyhow!("Comic not found"))?
            .into_active_model();
        comic.star = Set(star);
        comic.update(super::DB.get().unwrap()).await?;
        Ok(())
    }
}
