import { GlobalStore, UserStore, SCApp, LoginStatus } from '@handwer/base'
import { WearablePlayerUI } from '@handwer/wearable_player_ui'
import { WearableSettings } from '@handwer/wearable_settings'
import { RetryLoginPanel } from './views/RetryLoginPanel'
import { ArcSwiper } from '@ohos.arkui.ArcSwiper'
import { WearableMusicLibrary } from '@handwer/wearable_music_library'

@Entry
@ComponentV2
struct Index {
  gs = GlobalStore
  user = UserStore

  @Provider(SCApp.settingsSheet) consoleSheet: boolean = false

  @Local showLoginPanel: boolean = false
  @Local connectTimeout: boolean = false

  @Monitor('user.loginStatus')
  onLoginStatusChange() {
    this.showLoginPanel = UserStore.loginStatus !== LoginStatus.LOGGED && this.connectTimeout
  }

  @Builder retryLoginPanel() {
    RetryLoginPanel()
  }

  @Builder SettingsPanel() {
    WearableSettings()
  }

  build() {
    Row() {
      Column() {
        ArcSwiper() {
          WearablePlayerUI()
          WearableMusicLibrary()
        }
      }
      .bindSheet(this.consoleSheet!!, this.SettingsPanel, {
        preferType: SheetType.CENTER,
        backgroundColor: $r('app.color.ui_sheet_bg_col'),
        blurStyle: BlurStyle.BACKGROUND_THICK,
        showClose: false,
      })
    }
    .bindSheet(this.showLoginPanel!!, this.retryLoginPanel, {
      preferType: SheetType.CENTER,
      backgroundColor: $r('app.color.ui_sheet_bg_col'),
      blurStyle: BlurStyle.BACKGROUND_THICK,
      showClose: false,
      onWillDismiss: (data) => {
        if (UserStore.loginStatus === LoginStatus.LOGGED) {
          data.dismiss()
        }
      }
    })
    .height('100%')
    .width('100%')
    .onAppear(() => {
      this.onLoginStatusChange()
      setTimeout(() => {
        this.connectTimeout = true
        this.onLoginStatusChange()
      }, 1500)
    })
  }
}