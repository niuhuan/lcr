use sea_orm::entity::prelude::*;
use sea_orm::ActiveValue::Set;
use sea_orm::{ActiveModelBehavior, IntoActiveModel, QueryOrder};

#[derive(Clone, Debug, PartialEq, Eq, DeriveEntityModel)]
#[sea_orm(table_name = "comic_chapter")]
#[flutter_rust_bridge::frb(dart_metadata=("freezed"), mirror(ComicChapter))]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = false)]
    pub id: String,
    pub comic_id: String,
    pub title: String,
    pub index_in_comic: i32,
    pub image_count: i32,
}

pub type ComicChapter = Model;

#[derive(Copy, Clone, Debug, EnumIter, DeriveRelation)]
pub enum Relation {
    #[sea_orm(
        belongs_to = "super::comic::Entity",
        from = "Column::ComicId",
        to = "super::comic::Column::Id"
    )]
    Comic,
    #[sea_orm(has_many = "super::comic_image::Entity")]
    ComicImage,
}

impl Related<super::comic::Entity> for Entity {
    fn to() -> RelationDef {
        Relation::Comic.def()
    }
}

impl Related<super::comic_image::Entity> for Entity {
    fn to() -> RelationDef {
        Relation::ComicImage.def()
    }
}

impl ActiveModelBehavior for ActiveModel {}

impl Entity {
    pub async fn create_chapter(
        comic_id: &str,
        chapter_name: Option<&str>,
        index_in_comic: i32,
    ) -> anyhow::Result<String> {
        let id = uuid::Uuid::new_v4().to_string();
        let chapter = Model {
            id: id.clone(),
            comic_id: comic_id.to_string(),
            title: chapter_name.unwrap_or("Unnamed Chapter").to_string(),
            index_in_comic,
            image_count: 0,
        };
        Self::insert(chapter.into_active_model())
            .exec(super::DB.get().unwrap())
            .await?;
        Ok(id)
    }

    pub async fn delete_by_comic_id(comic_id: &str) -> anyhow::Result<()> {
        Self::delete_many()
            .filter(Column::ComicId.eq(comic_id))
            .exec(super::DB.get().unwrap())
            .await?;
        Ok(())
    }

    pub async fn update_image_count(id: &str, count: i32) -> anyhow::Result<()> {
        let mut chapter: ActiveModel = Self::find_by_id(id)
            .one(super::DB.get().unwrap())
            .await?
            .ok_or_else(|| anyhow::anyhow!("Chapter not found"))?
            .into_active_model();
        chapter.image_count = Set(count);
        chapter.update(super::DB.get().unwrap()).await?;
        Ok(())
    }

    pub async fn find_by_comic_id(comic_id: &str) -> anyhow::Result<Vec<Model>> {
        Ok(Self::find()
            .filter(Column::ComicId.eq(comic_id))
            .order_by_asc(Column::IndexInComic)
            .all(super::DB.get().unwrap())
            .await?)
    }
}
