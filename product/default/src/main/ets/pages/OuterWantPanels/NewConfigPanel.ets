import { SettingsMainPage } from "@handwer/app_settings"
import { GlobalContext, GlobalStore, OuterWantDataModel, SCApp, SCGlobal } from "@handwer/base"
import { LightUpLongButton } from "@handwer/ui_components"
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
      Text($r('app.string.first_open_page_panel_close_hint')).fontColor(Color.White)
      LightUpLongButton({
        title: $r('app.string.first_open_page_start_use'),
        icon: $r('sys.symbol.download'),
        clickAction: () => {
          this.openDataSourceSettings()
        }
      })
    }
  }

  @Builder Main() {
    NavDestination() {
      ImageTitleWelcomeTemplate({
        customImage: this.header,
        title: $r('app.string.first_open_page_external_share_config'),
        subtitle: $r('app.string.first_open_page_external_config_subtitle', this.want?.data['apiName'] ?? ''),
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