import { GlobalStore, SCApp } from "@handwer/base";
import { HDS_TITLE_CONFIG_STYLE } from "@handwer/ui_components";
import { HdsNavDestination, HdsNavDestinationAttribute } from "@kit.UIDesignKit";

@ComponentV2
export struct AboutPage {
  @Local version: string = ''
  @Local pageOpacity: number = 1
  @Consumer(SCApp.settingsPageStack) settingsPageStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.version = GlobalStore.appVersion
  }

  private logCounter: number = 0;

  build() {
    HdsNavDestination() {
      Column() {
        Column() {
          Image($r('sys.media.ohos_app_icon'))
            .width(90)
            .height(90)
            .onClick(() => {
              ++this.logCounter;
              if (this.logCounter > 5) {
                // this.settingsPageStack.pushPathByName('LogPage', [])
              }
            })
          Text($r('app.string.app_name'))
            .margin({top: 12})
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
          // Blank().height(8)
          Text(this.version)
            .fontColor($r('sys.color.font_secondary'))
        }.padding({top: 48})
        Column() {
          Text($r('app.string.about_info'))
            .fontSize(12)
          // Text('鲁ICP备2024108938号-2A')
          //   .fontSize(12)
          // Text($r('app.string.special_thanks'))
          //   .fontSize(12)
        }
      }.height('100%')
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({top: $r('sys.float.ohos_id_navigation_bar_height'), bottom: 48})
    }.titleBar({
      style: HDS_TITLE_CONFIG_STYLE,
      content: {
        title: {
          mainTitle: $r('app.string.about_this_app')
        }
      }
    }).backgroundColor(Color.Transparent)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .opacity(this.pageOpacity)
    .animation({duration: 300})
  }
}