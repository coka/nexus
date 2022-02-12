use druid::widget::{Flex, Label};
use druid::{AppLauncher, PlatformError, Widget, WindowDesc};

fn build_ui() -> impl Widget<()> {
    Flex::row()
        .with_flex_child(
            Flex::column().with_flex_child(Label::new("hello"), 1.0),
            1.0,
        )
        .with_flex_child(Label::new("world"), 1.0)
}

fn main() -> Result<(), PlatformError> {
    let window = WindowDesc::new(build_ui());
    AppLauncher::with_window(window).launch(())?;
    Ok(())
}
