import { GlobalStore, SCApp } from "@handwer/base";

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
        // Title Bar
        Row() {
          Image($r('sys.symbol.chevron_backward'))
            .width(24)
            .height(24)
            .fillColor(Color.White)
            .onClick(() => {
              this.settingsPageStack.pop()
            })
          Text($r('app.string.about_this_app'))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .margin({ left: 12 })
          Blank()
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })

        Column() {
          Column() {
            Image($r('sys.media.ohos_app_icon'))
              .width(60)
              .height(60)
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

          Column() {
            Text($r('app.string.about_info'))
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
              .textAlign(TextAlign.Center)
          }
          .margin({ top: 48 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ bottom: 48 })
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
