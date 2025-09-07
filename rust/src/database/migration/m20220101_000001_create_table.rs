use sea_orm::*;
use sea_orm_migration::prelude::*;

use crate::database::{comic_bookmark, comic_chapter, comic_image, comic_tag, AppSettingsEntity, ComicBookmarkEntity, ComicChapterEntity, ComicEntity, ComicImageEntity, ComicTagEntity, ReaderSettingsEntity};

#[derive(DeriveMigrationName)]
pub(super) struct Migration;

fn create_table_for_entity<E>(backend: DatabaseBackend, e: E) -> TableCreateStatement
where
    E: EntityTrait,
{
    let schema = Schema::new(backend);
    schema.create_table_from_entity(e)
}

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        let backend = manager.get_database_backend();
        manager
            .create_table(create_table_for_entity(backend, AppSettingsEntity))
            .await?;
        manager
            .create_table(create_table_for_entity(backend, ReaderSettingsEntity))
            .await?;
        manager
            .create_table(create_table_for_entity(backend, ComicEntity))
            .await?;
        manager
            .create_table(create_table_for_entity(backend, ComicChapterEntity))
            .await?;
        manager
            .create_table(create_table_for_entity(backend, ComicImageEntity))
            .await?;
        manager
            .create_table(create_table_for_entity(backend, ComicTagEntity))
            .await?;
        manager
            .create_table(create_table_for_entity(backend, ComicBookmarkEntity))
            .await?;
        manager
            .create_index(
                sea_query::Index::create()
                    .name("idx-comic_chapter-comic_id")
                    .table(ComicChapterEntity.table_name())
                    .col(comic_chapter::Column::ComicId)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                sea_query::Index::create()
                    .name("idx-comic_image-comic_id")
                    .table(ComicImageEntity.table_name())
                    .col(comic_image::Column::ComicId)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                sea_query::Index::create()
                    .name("idx-comic_image-comic_chapter_id")
                    .table(ComicImageEntity.table_name())
                    .col(comic_image::Column::ChapterId)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                sea_query::Index::create()
                    .name("idx-comic_tag-comic_id")
                    .table(ComicTagEntity.table_name())
                    .col(comic_tag::Column::ComicId)
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                sea_query::Index::create()
                    .name("idx-comic_tag-comic_id-tag")
                    .table(ComicTagEntity.table_name())
                    .col(comic_tag::Column::ComicId)
                    .col(comic_tag::Column::Tag)
                    .unique()
                    .to_owned(),
            )
            .await?;
        manager
            .create_index(
                sea_query::Index::create()
                    .name("idx-comic_bookmark-comic_id")
                    .table(ComicBookmarkEntity.table_name())
                    .col(comic_bookmark::Column::ComicId)
                    .to_owned(),
            )
            .await?;
        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        let mut drop = sea_query::Table::drop();
        drop.table(AppSettingsEntity.table_name())
            .table(ReaderSettingsEntity.table_name())
            .table(ComicBookmarkEntity.table_name())
            .table(ComicTagEntity.table_name())
            .table(ComicImageEntity.table_name())
            .table(ComicChapterEntity.table_name())
            .table(ComicEntity.table_name())
            .if_exists();
        manager.drop_table(drop).await?;
        Ok(())
    }
}
