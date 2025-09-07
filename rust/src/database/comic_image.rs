use sea_orm::entity::prelude::*;
use sea_orm::{ActiveModelBehavior, ColumnTrait, EntityTrait, QueryFilter, QueryOrder};

#[derive(Clone, Debug, PartialEq, Eq, DeriveEntityModel, Default)]
#[sea_orm(table_name = "comic_image")]
#[flutter_rust_bridge::frb(dart_metadata=("freezed"), mirror(ComicImage))]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = false)]
    pub id: String,
    pub comic_id: String,
    pub chapter_id: String,
    pub index_in_chapter: i32,
    pub path: String,
    pub width: i32,
    pub height: i32,
    pub format: String,
    pub status: String,
}

pub type ComicImage = Model;

#[derive(Copy, Clone, Debug, EnumIter, DeriveRelation)]
pub enum Relation {
    #[sea_orm(
        belongs_to = "super::comic::Entity",
        from = "Column::ComicId",
        to = "super::comic::Column::Id"
    )]
    Comic,
    #[sea_orm(
        belongs_to = "super::comic_chapter::Entity",
        from = "Column::ChapterId",
        to = "super::comic_chapter::Column::Id"
    )]
    ComicChapter,
}

impl Related<super::comic::Entity> for Entity {
    fn to() -> RelationDef {
        Relation::Comic.def()
    }
}
impl Related<super::comic_chapter::Entity> for Entity {
    fn to() -> RelationDef {
        Relation::ComicChapter.def()
    }
}

impl ActiveModelBehavior for ActiveModel {}

impl Entity {
    pub async fn delete_by_comic_id(comic_id: &str) -> anyhow::Result<()> {
        Self::delete_many()
            .filter(Column::ComicId.eq(comic_id))
            .exec(super::DB.get().unwrap())
            .await?;
        Ok(())
    }

    pub async fn find_by_chapter_id(chapter_id: &str) -> anyhow::Result<Vec<Model>> {
        Ok(Self::find()
            .filter(Column::ChapterId.eq(chapter_id))
            .order_by_asc(Column::IndexInChapter)
            .all(super::DB.get().unwrap())
            .await?)
    }
}
