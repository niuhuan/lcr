use std::collections::HashSet;

use sea_orm::entity::prelude::*;
use sea_orm::{ActiveModelBehavior, ColumnTrait, EntityTrait, IntoActiveModel, QueryFilter};

#[derive(Clone, Debug, PartialEq, Eq, DeriveEntityModel)]
#[sea_orm(table_name = "comic_tag")]
#[flutter_rust_bridge::frb(dart_metadata=("freezed"), mirror(ComicTag))]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = false)]
    pub id: String,
    pub comic_id: String,
    pub tag: String,
}

pub type ComicTag = Model;

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

    pub async fn find_by_comic_id(comic_id: &str) -> anyhow::Result<Vec<Model>> {
        let tags = Self::find()
            .filter(Column::ComicId.eq(comic_id))
            .all(super::DB.get().unwrap())
            .await?;
        Ok(tags)
    }

    pub async fn find_by_comic_ids(comic_ids: Vec<String>) -> anyhow::Result<Vec<Model>> {
        let tags = Self::find()
            .filter(Column::ComicId.is_in(comic_ids))
            .all(super::DB.get().unwrap())
            .await?;
        Ok(tags)
    }

    pub async fn update_comic_tags(comic_id: &str, new_tags: Vec<String>) -> anyhow::Result<()> {
        let existing_tags = Self::find_by_comic_id(comic_id).await?;
        let existing_tag_set: HashSet<String> =
            existing_tags.iter().map(|t| t.tag.clone()).collect();
        let new_tag_set: HashSet<String> = new_tags.iter().cloned().collect();

        // tags to add
        for tag in new_tag_set.difference(&existing_tag_set) {
            let new_tag = Model {
                id: uuid::Uuid::new_v4().to_string(),
                comic_id: comic_id.to_string(),
                tag: tag.clone(),
            };
            Self::insert(new_tag.into_active_model())
                .exec(super::DB.get().unwrap())
                .await?;
        }

        // tags to remove
        for tag in existing_tag_set.difference(&new_tag_set) {
            if let Some(existing_tag) = existing_tags.iter().find(|t| &t.tag == tag) {
                Self::delete_by_id(&existing_tag.id)
                    .exec(super::DB.get().unwrap())
                    .await?;
            }
        }

        Ok(())
    }
}
