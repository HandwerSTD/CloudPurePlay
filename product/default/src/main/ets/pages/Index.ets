import { GlobalStore, LoginStatus, OuterWantDataModel, PlayControl, SCApp, UserStore} from '@handwer/base'
import { PlayerUI } from '@handwer/player_ui'
import { SettingsMainPage } from '@handwer/app_settings'
import { HdsSnackBar } from '@kit.UIDesignKit'
import { RetryLoginPanel } from '../views/RetryLoginPanel'
import { NewConfigPanel } from './OuterWantPanels/NewConfigPanel'
import { ReceiveShareSongPanel } from './OuterWantPanels/ReceiveShareSong'
import { stylusInteraction } from '@kit.Penkit'

const TAG = '[Index]'

@Entry
@ComponentV2
struct Index {
  gs = GlobalStore
  user = UserStore

  @Provider(SCApp.settingsSheet) consoleSheet: boolean = false

  @Local showLoginPanel: boolean = false
  @Local showOuterWantPanel: boolean = false
  @Local connectTimeout: boolean = false

  @Monitor('user.loginStatus')
  onLoginStatusChange() {
    this.showLoginPanel = (UserStore.loginStatus !== LoginStatus.LOGGED && this.connectTimeout) || UserStore.loginStatus === LoginStatus.NOT_LOGGED
  }
  @Monitor('gs.outerWant')
  onOuterWant() {
    if (this.gs.outerWant.type !== '') {
      this.showOuterWantPanel = true
    } else {
      this.showOuterWantPanel = false
    }
  }
  @Monitor('gs.isInForeground')
  onForegroundSwitch() {
    const playNext = () => {
      PlayControl.playNext()
    }
    const pausePlay = () => {

    }
    if (this.gs.isInForeground) {
      stylusInteraction.on("squeeze", playNext)
      stylusInteraction.on("doubleTap", playNext)
    } else {
      stylusInteraction.off("squeeze", playNext)
      stylusInteraction.off("doubleTap", playNext)
    }
  }

  @Builder retryLoginPanel() {
    RetryLoginPanel()
  }

  @Builder OuterWantPanel() {
    if (this.gs.outerWant.type === 'new_config') {
      NewConfigPanel()
    } else if (this.gs.outerWant.type === 'share_song') {
      ReceiveShareSongPanel()
    }
  }

  @Builder SettingsPanel() {
    SettingsMainPage()
  }

  build() {
    Row() {
      Column() {
        Column() {
          PlayerUI()
        }
        .bindSheet(this.showOuterWantPanel!!, this.OuterWantPanel, {
          preferType: SheetType.CENTER,
          backgroundColor: $r('app.color.ui_sheet_bg_col'),
          blurStyle: BlurStyle.BACKGROUND_THICK,
          showClose: false,
          onWillDisappear: () => {
            this.gs.outerWant = new OuterWantDataModel('', {})
          }
        })
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
      this.onOuterWant()
      setTimeout(() => {
        this.connectTimeout = true
        this.onLoginStatusChange()
        this.onOuterWant()
      }, 3000)
    })
  }
}
