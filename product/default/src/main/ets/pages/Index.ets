import { GlobalStore, Logger, PlayControl, PlayListOp,
  SCApp,
  SCPref, SCUser, Settings,
  UserManager,
  UserSettings } from '@handwer/base'
import {
  AlbumAPIUtils,
  CloudAPIConfigUtils, LoginAPIUtils, RealIP_INITIAL, SongAPIUtils, User } from '@handwer/api_adapter'
import { PlayerUI } from '@handwer/player_ui'
import { promptAction } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'
import { ToastUtil } from '@pura/harmony-utils'
import { SettingsMainPage } from '@handwer/app_settings'

const TAG = '[Index]'

@Entry
@ComponentV2
struct Index {
  gs = GlobalStore

  @Provider(SCApp.settingsSheet) consoleSheet: boolean = false
  @Builder testConsole() {
    SettingsMainPage()
  }

  build() {
    Column() {
      PlayerUI()
    }
    .bindSheet(this.consoleSheet!!, this.testConsole, {
      preferType: SheetType.CENTER,
      backgroundColor: Color.Transparent,
      showClose: false
    })
    .height('100%')
    .width('100%')
  }
}
