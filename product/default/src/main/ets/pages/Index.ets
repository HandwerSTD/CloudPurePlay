import { GlobalStore, LoginStatus, SCApp, UserStore} from '@handwer/base'
import { PlayerUI } from '@handwer/player_ui'
import { SettingsMainPage } from '@handwer/app_settings'
import { HdsSnackBar } from '@kit.UIDesignKit'
import { RetryLoginPanel } from '../views/RetryLoginPanel'

const TAG = '[Index]'

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
    SettingsMainPage()
  }

  build() {
    Row() {
      Column() {
        PlayerUI()
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
      this.gs.globalSnack = new HdsSnackBar(this.getUIContext())
      this.onLoginStatusChange()
      setTimeout(() => {
        this.connectTimeout = true
        this.onLoginStatusChange()
      }, 3000)
    })
  }
}
