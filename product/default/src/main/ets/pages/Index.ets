import { GlobalStore, Logger, LoginStatus, AmbientLightUtils,
  NowPlayingStore,
  OuterWantDataModel, PlayControl, SCApp, UserStore,
  ThemeManager,
  AppColorMode} from '@handwer/base'
import { PlayerUI } from '@handwer/player_ui'
import { SettingsMainPage } from '@handwer/app_settings'
import { hdsEffect, HdsSnackBar } from '@kit.UIDesignKit'
import { RetryLoginPanel } from '../views/RetryLoginPanel'
import { NewConfigPanel } from './OuterWantPanels/NewConfigPanel'
import { ReceiveShareSongPanel } from './OuterWantPanels/ReceiveShareSong'
import { stylusInteraction } from '@kit.Penkit'
import { BgFlowController, SnackBarUtils } from '@handwer/ui_components'

const TAG = '[Index]'

@Entry
@ComponentV2
struct Index {
  gs = GlobalStore
  user = UserStore

  @Provider(SCApp.settingsSheet) consoleSheet: boolean = false
  @Provider(SCApp.outerWantPanel) showOuterWantPanel: boolean = false
  @Provider(SCApp.exploreSheet) showExplore: boolean = false

  @Local showLoginPanel: boolean = false
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
    // Light sensor monitoring for theme switching
    try {
      if (this.gs.isInForeground && ThemeManager.getSingleton().appColorModeStat === AppColorMode.SMART_MODE) {
        // Register light sensor listener when app comes to foreground
        AmbientLightUtils.registerLightSensorListener(
          this.getUIContext().getHostContext()!.getApplicationContext(),
          (isLowLight) => {
            SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.dark_mode'), isLowLight ? $r('app.string.auto_switched_to_dark') : $r('app.string.auto_switched_to_light'))
          }
        )
        Logger.info(TAG, 'Light sensor listener registered')
      } else {
        // Unregister light sensor listener when app goes to background
        AmbientLightUtils.unregisterLightSensorListener()
        Logger.info(TAG, 'Light sensor listener unregistered')
      }
    } catch (e) {
      Logger.error(TAG, `Error managing light sensor: ${e.message}`)
    }

    // stylus
    try {
      const playNext = () => {
        PlayControl.playNext()
      }
      const pausePlay = () => {
        if (NowPlayingStore.isPaused) {
          PlayControl.resumeMusic()
        } else {
          PlayControl.pauseMusic()
        }
      }
      if (GlobalStore.pref.useStylusControl) {
        if (this.gs.isInForeground) {
            stylusInteraction.on("squeeze", () => {
              pausePlay()
            })
            stylusInteraction.on("doubleTap", () => {
              playNext()
            })
        } else {
          stylusInteraction.off("squeeze")
          stylusInteraction.off("doubleTap")
        }
      }
    } catch (e) {
      Logger.error(`Index`, `err on setting stylusInteraction: ${e.message}`)
    }
    // bgFlow
    const flow = BgFlowController.getInstance()
    if (this.gs.isInForeground) {
      flow.resume()
    } else {
      flow.pause()
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
      this.onForegroundSwitch()
      setTimeout(() => {
        this.connectTimeout = true
        this.onLoginStatusChange()
        this.onOuterWant()
      }, 3000)
    })
  }
}
