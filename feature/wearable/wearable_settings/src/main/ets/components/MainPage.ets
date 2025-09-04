import { GlobalContext, SCApp, SCGlobal } from "@handwer/base";
import { ArcList,ArcListAttribute, ArcListItem,ArcListItemAttribute, promptAction } from "@kit.ArkUI";
import { ArcConst, ArcCommonListItem } from "@handwer/wearable_ui_components";
import { common, OpenLinkOptions } from '@kit.AbilityKit';
import { router } from "@kit.ArkUI";
import { AboutPage } from "../views/AboutPage";
import { APIFinishWelcome } from "../views/DataSource/APIFinishWelcome";
import { CloudAPI_Source } from "../views/DataSource/CloudAPI";
import { DataSourceSettings, DeviceSelectorPanel } from "../views/DataSource/DataSourceSettings";
import { NavidromeAPI_Source } from "../views/DataSource/NavidromeAPI";
import { DisplaySettings } from "../views/DisplaySettings/DisplaySettings";
import { MissionContinueSettings } from "../views/MissionContinue/MissionContinueSettings";
import { PlaybackSettings } from "../views/PlaybackSettings/PlaybackSettings";

@ComponentV2
export struct MainPage {
  @Param onOuterPop: (() => void) | undefined = undefined
  @Consumer(SCApp.settingsSheet) consoleSheet: boolean = false
  @Provider(SCApp.settingsPageStack) pageStack: NavPathStack = new NavPathStack()
  @Local pageOpacity: number = 1

  quickJump?: string

  aboutToAppear(): void {
    this.quickJump = GlobalContext.getContext().getObject(SCGlobal.app_settings_quickJump) as string | undefined
    this.pageStack.pushPathByName('Main', [], false)
    if (this.quickJump) {
      this.pageStack.pushPathByName(this.quickJump, [], false)
    }
    GlobalContext.getContext().deleteObject(SCGlobal.app_settings_quickJump)
  }

  @Builder pageMap(name: string) {
    if (name === 'DataSourceSettings') {
      DataSourceSettings()
    } else if (name === 'Main') {
      this.Main()
    } else if (name === 'AboutPage') {
      AboutPage()
    } else if (name === 'CloudAPI_Source') {
      CloudAPI_Source()
    } else if (name === 'NavidromeAPI_Source') {
      NavidromeAPI_Source()
    } else if (name === 'APIFinishWelcome') {
      APIFinishWelcome()
    } else if (name === 'MissionContinueSettings') {
      MissionContinueSettings()
    } else if (name === 'DisplaySettings') {
      DisplaySettings()
    } else if (name === 'PlaybackSettings') {
      PlaybackSettings()
    } else if (name === 'DataSyncPanel') {
      DeviceSelectorPanel()
    }
  }

  @Builder DataSource() {
    ArcCommonListItem({
      icon: $r('sys.symbol.play_circle_badge_music_note'),
      title: $r('app.string.data_source')
    })
      .onClick(() => {
        this.pushPage('DataSourceSettings', {})
      })
  }

  @Builder MultiDevice() {
    ArcCommonListItem({
      icon: $r('sys.symbol.Interconnection_ic_multiscreen_collaboration'),
      title: $r('app.string.mission_continue')
    })
      .onClick(() => {
        this.pushPage('MissionContinueSettings', {})
      })
  }

  @Builder DisplaySettingsBuilder() {
    ArcCommonListItem({
      icon: $r('sys.symbol.square_grid_2x2'),
      title: $r('app.string.display_settings')
    })
      .onClick(() => {
        this.pushPage('DisplaySettings', {})
      })
  }

  @Builder PlaybackSettingsBuilder() {
    ArcCommonListItem({
      icon: $r('sys.symbol.play'),
      title: $r('app.string.playback_settings')
    })
      .onClick(() => {
        this.pushPage('PlaybackSettings', {})
      })
  }

  @Builder OpenFirstStart() {
    ArcCommonListItem({
      icon: $r('sys.symbol.bolt_lightbulb_max'),
      title: $r('app.string.open_first_start')
    })
      .onClick(() => {
        router.replaceUrl({
          url: 'pages/FirstOpenSubPages/FirstOpenPage'
        })
      })
  }

  @Builder JoinGroup() {
    ArcCommonListItem({
      icon: $r('sys.symbol.doc_plaintext_and_pencil'),
      title: $r('app.string.join_group')
    })
      .onClick(() => {
        promptAction.openToast({
          message: $r('app.string.opening_group')
        })
        startQQGroupAbility(getContext() as common.UIAbilityContext, 982093132)
      })
  }

  @Builder AboutApp() {
    ArcCommonListItem({
      icon: $r('sys.symbol.info_circle'),
      title: $r('app.string.about_this_app')
    })
      .onClick(() => {
        this.pushPage('AboutPage', {})
      })
  }

  @Builder Main() {
    NavDestination() {
      Column() {
        ArcList() {
          ArcListItem() {
            this.DataSource()
          }.width(ArcConst.ARC_LIST_W)
          // ArcListItem() {
          //   this.DisplaySettingsBuilder()
          // }.width(ArcConst.ARC_LIST_W)
          ArcListItem() {
            this.PlaybackSettingsBuilder()
          }.width(ArcConst.ARC_LIST_W)
          ArcListItem() {
            this.MultiDevice()
          }.width(ArcConst.ARC_LIST_W)
          // ArcListItem() {
          //   this.OpenFirstStart()
          // }.width(ArcConst.ARC_LIST_W)
          // ArcListItem() {
          //   this.JoinGroup()
          // }.width(ArcConst.ARC_LIST_W)
          ArcListItem() {
            this.AboutApp()
          }.width(ArcConst.ARC_LIST_W)
        }
        .space(ArcConst.ARC_LIST_SPC)
        .fadingEdge(true)
      }
      .width('100%')
      .height('100%')
    }
    .onBackPressed(() => {
      this.consoleSheet = false
      return true
    })
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onShown(() => {
      if (this.quickJump) {
        this.onOuterPop?.()
      }
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .opacity(this.pageOpacity)
    .animation({ duration: 300 })
  }

  build() {
    Row() {
      Column() {
        Navigation(this.pageStack) {
        }
        .navDestination(this.pageMap)
        .backgroundColor(Color.Transparent)
      }
      .width('100%')
    }
    .height('100%')
  }

  pushPage(name: string, params: Record<string, Object>) {
    this.pageStack.pushPathByName(name, params, true)
  }
}

function startQQGroupAbility(context: common.UIAbilityContext, groupNum: number) {
  let openLinkOptions: OpenLinkOptions = {
    appLinkingOnly: false,
  }
  try {
    context.openLink('mqqapi://card/show_pslcard?src_type=internal&version=1&uin=' + groupNum +
      '&card_type=group&source=qrcode', openLinkOptions)
  } catch (paramError) {}
}
