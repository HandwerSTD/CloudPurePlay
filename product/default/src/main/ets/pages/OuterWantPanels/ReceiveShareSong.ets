import { SettingsMainPage } from "@handwer/app_settings"
import { GlobalContext, GlobalStore, OuterWantDataModel, PlayControl, SCApp, SCGlobal } from "@handwer/base"
import { LightUpLongButton } from "@handwer/ui_components"
import { HdsSnackBar } from "@kit.UIDesignKit"
import { ImageTitleWelcomeTemplate, SymbolTitle } from "../FirstOpenSubPages/CommonTemplate"

@ComponentV2
export struct ReceiveShareSongPanel {
  snack = new HdsSnackBar(this.getUIContext())
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
    }
  }

  @Builder header() {
    SymbolTitle({
      icon: $r('sys.symbol.music_fill'),
      gradientColor:[0x7180d7, 0xdaa0fe]
    })
  }
  @Builder footer() {
    Column({space: 12}) {
      Text($r('app.string.first_open_page_panel_close_hint')).fontColor(Color.White)
      LightUpLongButton({
        title: $r('app.string.click_to_play'),
        icon: $r('sys.symbol.play_round_triangle_fill'),
        clickAction: () => {
          PlayControl.playSongFromShareLink(this.want!.data['url'] as string)
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
}