use sea_orm::entity::prelude::*;
use sea_orm::NotSet;
use sea_orm::Set;

#[derive(Clone, Debug, PartialEq, Eq, DeriveEntityModel)]
#[sea_orm(table_name = "reader_settings")]
#[flutter_rust_bridge::frb(mirror(ReaderSettings))]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = true)]
    pub id: i64,
    pub settings_type: String, // 设置类型: DEFAULT (默认), COMIC (漫画), TEMPLATE (模板)
    pub comic_id: String,      // 漫画ID (如果是漫画)
    pub template_name: String, // 模板名称 (如果是模板)
    pub background_color: i64, // 背景颜色
    pub reader_type: String,   // 阅读器类型
    pub touch_type: String,    // 阅读器事件类型
    pub reader_direction: String, // 阅读器方向
    pub image_filter: String,  // 图片滤镜
    pub margin_top: i64,       // 上边距
    pub margin_bottom: i64,    // 下边距
    pub margin_left: i64,      // 左边距
    pub margin_right: i64,     // 右边距
    pub annotation: bool,      // 翻页动画类型
    pub scroll_type: String,   // 滚动类型
    pub scroll_percent: i64,   // 滚动百分比
}

pub type ReaderSettings = Model;

#[derive(Copy, Clone, Debug, EnumIter, DeriveRelation)]
pub enum Relation {}

impl ActiveModelBehavior for ActiveModel {}

impl Entity {
    pub async fn find_default() -> anyhow::Result<Option<Model>> {
        let reader_settings = Self::find_by_id(0).one(super::DB.get().unwrap()).await?;
        Ok(reader_settings)
    }

    pub async fn find_by_comic_id(comic_id: &str) -> anyhow::Result<Option<Model>> {
        let setting = Self::find()
            .filter(Column::SettingsType.eq("COMIC"))
            .filter(Column::ComicId.eq(comic_id))
            .one(super::DB.get().unwrap())
            .await?;
        Ok(setting)
    }

    pub async fn find_by_template_name(template_name: &str) -> anyhow::Result<Option<Model>> {
        let setting = Self::find()
            .filter(Column::SettingsType.eq("TEMPLATE"))
            .filter(Column::TemplateName.eq(template_name))
            .one(super::DB.get().unwrap())
            .await?;
        Ok(setting)
    }

    pub async fn save_or_update_by_comic_id(model: Model) -> anyhow::Result<()> {
        let db = super::DB.get().unwrap();
        let existing = Self::find()
            .filter(Column::ComicId.eq(model.comic_id.clone()))
            .one(db)
            .await?;
        if let Some(existing) = existing {
            let mut active_model: ActiveModel = existing.into();
            active_model.background_color = Set(model.background_color);
            active_model.reader_type = Set(model.reader_type);
            active_model.touch_type = Set(model.touch_type);
            active_model.reader_direction = Set(model.reader_direction);
            active_model.image_filter = Set(model.image_filter);
            active_model.margin_top = Set(model.margin_top);
            active_model.margin_bottom = Set(model.margin_bottom);
            active_model.margin_left = Set(model.margin_left);
            active_model.margin_right = Set(model.margin_right);
            active_model.annotation = Set(model.annotation);
            active_model.scroll_type = Set(model.scroll_type);
            active_model.scroll_percent = Set(model.scroll_percent);
            active_model.update(db).await?;
        } else {
            let mut active_model: ActiveModel = model.into();
            active_model.id = NotSet;
            active_model.settings_type = Set("COMIC".to_string());
            Self::insert(active_model).exec(db).await?;
        }
        Ok(())
    }

    pub async fn delete_by_comic_id(comc_id: &str) -> anyhow::Result<()> {
        let db = super::DB.get().unwrap();
        let existing = Self::find()
            .filter(Column::SettingsType.eq("COMIC"))
            .filter(Column::ComicId.eq(comc_id))
            .one(db)
            .await?;
        if let Some(existing) = existing {
            let active_model: ActiveModel = existing.into();
            active_model.delete(db).await?;
        }
        Ok(())
    }
}
