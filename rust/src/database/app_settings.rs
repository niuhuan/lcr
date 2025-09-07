use sea_orm::{entity::prelude::*, IntoActiveModel};

#[derive(
    Clone, Debug, PartialEq, Eq, DeriveEntityModel, Default, serde::Serialize, serde::Deserialize,
)]
#[sea_orm(table_name = "app_settings")]
#[flutter_rust_bridge::frb(dart_metadata=("freezed"), mirror(AppSettings))]
pub struct Model {
    #[sea_orm(primary_key, auto_increment = true)]
    pub id: i64,
    pub theme: String,                      // 主题
    pub dark_theme: String,                 // 暗色主题
    pub copy_skip_confirm: bool,            // 复制时是否跳过确认
    pub copy_comic_title_template: String,  // 复制时漫画标题的模板
    pub auto_full_screen_into_reader: bool, // 自动全屏进入阅读器
    pub book_list_type: String,             // 书籍列表类型
    pub font_scale_percent: i32,            // 字体缩放%
    pub cover_width: i32,                   // 封面宽度
    pub cover_height: i32,                  // 封面高度
    pub annotation: bool,                   // 翻页动画类型
    pub full_screen_remove_bars: bool,      // 全屏时隐藏状态栏和导航栏
}

pub type AppSettings = Model;

#[derive(Copy, Clone, Debug, EnumIter, DeriveRelation)]
pub enum Relation {}

impl ActiveModelBehavior for ActiveModel {}

impl Entity {
    pub async fn find_by_id_a(id: i64) -> anyhow::Result<Option<Model>> {
        Ok(Self::find()
            .filter(Column::Id.eq(id))
            .one(super::DB.get().unwrap())
            .await?)
    }

    pub async fn save_default(mut model: Model) -> anyhow::Result<()> {
        model.id = 0;
        model
            .into_active_model()
            .update(super::DB.get().unwrap())
            .await?;
        Ok(())
    }
}
