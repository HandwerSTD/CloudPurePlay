import { GlobalStore, SCApp } from "@handwer/base";
import { ArcList, ArcListAttribute, ArcListItem, ArcListItemAttribute } from "@kit.ArkUI";
import { ArcConst } from "@handwer/wearable_ui_components";

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
    NavDestination() {
      Column() {
        ArcList() {
          ArcListItem() {
            Column() {
              Image($r('app.media.icon'))
                .width(60)
                .height(60).borderRadius(999)
                .onClick(() => {
                  ++this.logCounter;
                  if (this.logCounter > 5) {
                    // this.settingsPageStack.pushPathByName('LogPage', [])
                  }
                })
              Text($r('app.string.app_name'))
                .margin({ top: 12 })
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.White)
              Text(this.version)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize(14)
                .margin({ top: 4 })
            }
            .padding({ top: 48 })
          }
          .width(ArcConst.ARC_LIST_W)
          
          ArcListItem() {
            Column() {
              Text($r('app.string.about_info'))
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))
                .textAlign(TextAlign.Center)
            }
            .justifyContent(FlexAlign.Center)
            .padding({ bottom: 48 })
          }
          .width(ArcConst.ARC_LIST_W)
        }
        .space(ArcConst.ARC_LIST_SPC)
        .fadingEdge(true)
        .layoutWeight(1)
      }
      .height('100%')
      .width('100%')
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .opacity(this.pageOpacity)
    .animation({ duration: 300 })
  }
}
