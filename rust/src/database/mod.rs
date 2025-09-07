pub mod app_settings;
pub mod comic;
pub mod comic_bookmark;
pub mod comic_chapter;
pub mod comic_image;
pub mod comic_tag;
pub mod migration;
pub mod reader_settings;

use anyhow::Result;
use sea_orm::*;
use sea_orm_migration::prelude::*;
use tokio::sync::OnceCell;

pub use crate::database::app_settings::Entity as AppSettingsEntity;
pub use crate::database::comic::Entity as ComicEntity;
pub use crate::database::comic_bookmark::Entity as ComicBookmarkEntity;
pub use crate::database::comic_chapter::Entity as ComicChapterEntity;
pub use crate::database::comic_image::Entity as ComicImageEntity;
pub use crate::database::comic_tag::Entity as ComicTagEntity;
pub use crate::database::reader_settings::Entity as ReaderSettingsEntity;

pub(crate) static DB: OnceCell<DatabaseConnection> = OnceCell::const_new();

pub(crate) async fn set_up_db(database_path: &str) -> Result<()> {
    let db = Database::connect(format!("sqlite://{}?mode=rwc", database_path)).await?;
    DB.set(db)?;
    migration::Migrator::up(DB.get().unwrap(), None).await?;
    init_data(DB.get().unwrap()).await?;
    Ok(())
}

async fn init_data(db: &DatabaseConnection) -> Result<()> {
    let app_settings = AppSettingsEntity::find_by_id(0).one(db).await?;
    if app_settings.is_none() {
        let app_settings = app_settings::Model {
            id: 0,
            theme: "LIGHT".to_string(),
            dark_theme: "DARK".to_string(),
            copy_skip_confirm: false,
            copy_comic_title_template: "[{author}] {title}".to_string(),
            auto_full_screen_into_reader: false,
            book_list_type: "LIST_CARD".to_string(),
            font_scale_percent: 100,
            cover_width: 100,
            cover_height: 150,
            annotation: true,
            full_screen_remove_bars: false,
            enable_volume_control: false,
        };
        AppSettingsEntity::insert(app_settings.into_active_model())
            .exec(db)
            .await?;
    }
    let reader_settings = ReaderSettingsEntity::find_by_id(0).one(db).await?;
    if reader_settings.is_none() {
        let reader_settings = reader_settings::Model {
            id: 0,
            settings_type: "DEFAULT".to_string(),
            comic_id: "".to_string(),
            template_name: "".to_string(),
            background_color: 0x0,
            reader_type: "Gallery".to_string(),
            touch_type: "TouchNextDoubleFullScreen".to_string(),
            reader_direction: "TopToBottom".to_string(),
            image_filter: "NONE".to_string(),
            margin_top: 0,
            margin_bottom: 0,
            margin_left: 0,
            margin_right: 0,
            annotation: false,
            scroll_type: "Page".to_string(),
            scroll_percent: 60,
        };
        ReaderSettingsEntity::insert(reader_settings.into_active_model())
            .exec(db)
            .await?;
    }
    Ok(())
}
