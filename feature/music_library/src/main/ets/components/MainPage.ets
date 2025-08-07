import { HDS_TITLE_CONFIG_STYLE } from "@handwer/ui_components"
import { HdsNavigation, HdsNavigationAttribute, HdsNavigationTitleMode } from "@kit.UIDesignKit"

@ComponentV2
export struct MainPage {

  build() {
    Row() {
      Column() {
        HdsNavigation() {

        }.titleBar({
          style: HDS_TITLE_CONFIG_STYLE,
          content: {
            title: {
              mainTitle: $r('app.string.My_Music_Library'),
            }
          }
        }).titleMode(HdsNavigationTitleMode.FULL).mode(NavigationMode.Stack)
      }
      .width('100%')
    }
    .height('100%')
  }
}
