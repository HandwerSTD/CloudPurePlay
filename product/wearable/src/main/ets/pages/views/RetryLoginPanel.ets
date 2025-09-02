import { LoginAPIUtils, User_INITIAL } from "@handwer/api_adapter";
import { GlobalContext, LoginStatus,
  PlayControl,
  SCApp,
  SCEmitter,
  SCGlobal, UserManager, UserStore } from "@handwer/base";
import { WearableSettings } from "@handwer/wearable_settings";
import { DialogHelper } from "@pura/harmony-dialog";
import { EmitterUtil } from "@pura/harmony-utils";
import { ImageTitleWelcomeTemplate } from "../FirstOpenSubPages/CommonTemplate";

@ComponentV2
export struct RetryLoginPanel {
  @Consumer(SCApp.retryLoginSheet) retrySheet: boolean = false
  @Provider(SCApp.settingsSheet) consoleSheet: boolean = true // 覆盖一下 Index 的 Provider
  pageStack: NavPathStack = new NavPathStack()
  @Local pageOpacity: number = 1

  aboutToAppear(): void {
    this.pageStack.pushPathByName('Main', [], false)
  }

  @Builder pageMap(name: string) {
    if (name === 'Main') {
      this.Main()
    } else if (name === 'DataSource') {
      NavDestination() {
        WearableSettings({
          onOuterPop: () => {
            this.pageStack.popToName('Main', true)
          }
        })
      }.hideTitleBar(true)
      .backgroundColor(Color.Transparent)
    }
  }

  get isNotLogged() {
    return UserStore.loginStatus === LoginStatus.NOT_LOGGED
  }
  get isLoginFailed() {
    return UserStore.loginStatus === LoginStatus.LOGIN_FAILED
  }

  @Builder Main() {
    NavDestination() {
      if (this.isNotLogged) {
        NotLoggedContent({
          pushPage: (n) => this.pageStack.pushPathByName(n, [], true)
        }).transition(TransitionEffect.OPACITY.animation({duration: 300}))
      } else if (this.isLoginFailed) {
        LoginFailedContent({
          pushPage: (n) => this.pageStack.pushPathByName(n, [], true)
        }).transition(TransitionEffect.OPACITY.animation({duration: 300}))
      } else {
          Column() {
            LoadingProgress()
              .width(50)
              .color(Color.White)
            Text($r('app.string.retry_login_panel_show_reason'))
              .fontSize(14)
              .padding(48)
              .textAlign(TextAlign.Center)
              .fontColor(Color.White)
          }.width('100%').justifyContent(FlexAlign.Center)
        .transition(TransitionEffect.OPACITY.animation({duration: 300}))
        .height('100%').justifyContent(FlexAlign.Center)
      }
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

@ComponentV2
export struct NotLoggedContent {
  @Param @Require pushPage: (name: string) => void

  @Builder customHeader() {
    Column() {
      SymbolGlyph($r('sys.symbol.music_note_icolud'))
        .fontColor([Color.White])
        .fontWeight(FontWeight.Normal)
        .fontSize(50)
    }
    .width(100)
    .height(100)
    .justifyContent(FlexAlign.Center)
    .borderRadius(24)
    .linearGradient({
      angle: -75,
      colors: [[0x7180d7, 0], [0xdaa0fe, 1]]
    })
    .shadow(ShadowStyle.OUTER_FLOATING_SM)
  }

  build() {
    ImageTitleWelcomeTemplate({
      title: $r('app.string.Login'),
      subtitle: $r('app.string.not_logged_content_desc'),
      customImage: this.customHeader,
      useButtonFooter: true,
      buttonFooterText: $r('app.string.Login'),
      buttonFooterOnClick: () => {
        this.openDataSourceSettings()
      }
    })
  }

  openDataSourceSettings() {
    GlobalContext.getContext().setObject(SCGlobal.app_settings_quickJump, 'DataSourceSettings')
    this.pushPage('DataSource')
  }
}
@ComponentV2
export struct LoginFailedContent {
  @Param @Require pushPage: (name: string) => void

  @Builder customHeader() {
    Column() {
      SymbolGlyph($r('sys.symbol.music_note_icolud'))
        .fontColor([Color.White])
        .fontWeight(FontWeight.Normal)
        .fontSize(50)
    }
    .width(100)
    .height(100)
    .justifyContent(FlexAlign.Center)
    .borderRadius(24)
    .linearGradient({
      angle: -75,
      colors: [[0x7180d7, 0], [0xdaa0fe, 1]]
    })
    .shadow(ShadowStyle.OUTER_FLOATING_SM)
  }
  @Builder customFooter() {
    Column({space: 12}) {
        Button($r('app.string.switch_account')).width('100%')
          .buttonStyle(ButtonStyleMode.NORMAL)
          .onClick(() => {
            this.openDataSourceSettings()
          })

        Button($r('app.string.check_connectivity')).width('100%')
          .onClick(() => {
            const id = DialogHelper.showLoadingDialog()
            LoginAPIUtils.getLoginStatus((val) => {
              if (val.data.profile.userId !== User_INITIAL.data.profile.userId) {
                UserManager.init()
                  .then(() => {
                    EmitterUtil.post(SCEmitter.UserInfoReInit, {})
                  })
                  .finally(() => {
                    DialogHelper.closeDialog(id)
                  })
              } else {
                DialogHelper.closeDialog(id)
              }
            })
              .catch(() => {
                DialogHelper.closeDialog(id)
              })
          })
    }
  }

  build() {
    ImageTitleWelcomeTemplate({
      title: $r('app.string.login_failed'),
      subtitle: $r('app.string.login_failed_desc'),
      customImage: this.customHeader,
      footer: () => {
        this.customFooter()
      }
    })
  }

  openDataSourceSettings() {
    GlobalContext.getContext().setObject(SCGlobal.app_settings_quickJump, 'DataSourceSettings')
    this.pushPage('DataSource')
  }
}