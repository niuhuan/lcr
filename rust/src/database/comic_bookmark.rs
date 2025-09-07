use sea_orm::entity::prelude::*;
use sea_orm::{ActiveModelBehavior, ColumnTrait, EntityTrait, QueryFilter};

#[derive(Clone, Debug, PartialEq, Eq, DeriveEntityModel)]
#[sea_orm(table_name = "comic_bookmark")]
#[flutter_rust_bridge::frb(dart_metadata=("freezed"), mirror(ComicBookmark))]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = true)]
    pub id: i64,
    pub comic_id: String,
    pub comic_title: String,
    pub edit_time: i64,
    pub mark_chapter_id: String,
    pub mark_chapter_title: String,
    pub mark_page_index: i32,
}

pub type ComicBookmark = Model;

#[derive(Copy, Clone, Debug, EnumIter, DeriveRelation)]
pub enum Relation {
    #[sea_orm(
        belongs_to = "super::comic::Entity",
        from = "Column::ComicId",
        to = "super::comic::Column::Id"
    )]
    Comic,
}

impl Related<super::comic::Entity> for Entity {
    fn to() -> RelationDef {
        Relation::Comic.def()
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
}
