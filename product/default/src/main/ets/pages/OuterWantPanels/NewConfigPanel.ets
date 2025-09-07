import { SettingsMainPage } from "@handwer/app_settings"
import { GlobalContext, GlobalStore, OuterWantDataModel, SCApp, SCGlobal } from "@handwer/base"
import { HdsSnackBar } from "@kit.UIDesignKit"
import { ImageTitleWelcomeTemplate, SymbolTitle } from "../FirstOpenSubPages/CommonTemplate"

@ComponentV2
export struct NewConfigPanel {
  snack = new HdsSnackBar(this.getUIContext())
  @Provider(SCApp.settingsSheet) consoleSheet: boolean = true // 覆盖一下 Index 的 Provider
  pageStack: NavPathStack = new NavPathStack()
  @Local pageOpacity: number = 1
  @Local want: OuterWantDataModel | undefined = undefined

  aboutToAppear(): void {
    this.want = GlobalStore.outerWant
    this.pageStack.pushPathByName('Main',[], false)
  }

  @Builder pageMap(name: string) {
    if (name === 'Main') {
      this.Main()
    } else if (name === 'DataSource') {
      NavDestination() {
        SettingsMainPage({
          onOuterPop: () => {
            this.pageStack.popToName('Main', true)
          }
        })
      }.hideTitleBar(true)
      .backgroundColor(Color.Transparent)
    }
  }

  @Builder header() {
    SymbolTitle({
      icon: $r('sys.symbol.play_circle_badge_music_note'),
      gradientColor:[0x7180d7, 0xdaa0fe]
    })
  }
  @Builder footer() {
    Column({space: 12}) {
      Text('下滑面板以关闭').fontColor(Color.White)
      Button('开始使用')
        .onClick(() => {
          this.openDataSourceSettings()
        })
        .width('100%')
    }
  }

  @Builder Main() {
    NavDestination() {
      ImageTitleWelcomeTemplate({
        customImage: this.header,
        title: '外部分享的配置',
        subtitle: `接收到来自 ${(this.want?.data['apiName'])} 的配置，点击下方按钮以配置。`,
        footer: () => {
          this.footer()
        }
      })
    }.onBackPressed(() => {
      return true
    }).hideTitleBar(true).backgroundColor(Color.Transparent)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .opacity(this.pageOpacity)
    .animation({duration: 300})
  }

  build() {
    Row() {
      Column() {
        Navigation(this.pageStack) {

        }
        .navDestination(this.pageMap)
        .backgroundColor(Color.Transparent)
        .mode(NavigationMode.Stack)
      }
      .width('100%')
    }
    .height('100%')
  }


  openDataSourceSettings() {
    GlobalContext.getContext().setObject(SCGlobal.app_settings_quickJump, 'DataSourceSettings')
    this.pageStack.pushPathByName('DataSource', [])
  }
}