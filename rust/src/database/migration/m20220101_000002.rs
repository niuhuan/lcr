use sea_orm::*;
use sea_orm_migration::prelude::*;

use crate::database::AppSettingsEntity;

#[derive(DeriveMigrationName)]
pub(super) struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        // alter app_settings add column full_screen_remove_bars boolean not null default 0
        let db = manager.get_connection();
        // 检查列是否存在
        let rows = db
            .query_all(sea_orm::Statement::from_string(
                sea_orm::DatabaseBackend::Sqlite,
                "PRAGMA table_info(app_settings);".to_string(),
            ))
            .await?;
        let exists = rows.iter().any(|row| {
            row.try_get::<String>("", "name")
                .map(|name| name == "full_screen_remove_bars")
                .unwrap_or(false)
        });
        if exists {
            return Ok(());
        }
        manager
            .alter_table(
                TableAlterStatement::new()
                    .table(AppSettingsEntity)
                    .add_column(
                        sea_orm::sea_query::ColumnDef::new(
                            crate::database::app_settings::Column::FullScreenRemoveBars,
                        )
                        .boolean()
                        .not_null()
                        .default(0),
                    )
                    .to_owned(),
            )
            .await?;
        Ok(())
    }

    async fn down(&self, _manager: &SchemaManager) -> Result<(), DbErr> {
        Ok(())
    }
}
