import { GlobalContext, SCApp, SCGlobal } from "@handwer/base";
import { ArcList,ArcListAttribute, ArcListItem,ArcListItemAttribute, promptAction } from "@kit.ArkUI";
import { common, OpenLinkOptions } from '@kit.AbilityKit';
import { router } from "@kit.ArkUI";
import { AboutPage } from "../views/AboutPage";
import { APIFinishWelcome } from "../views/DataSource/APIFinishWelcome";
import { CloudAPI_Source } from "../views/DataSource/CloudAPI";
import { DataSourceSettings } from "../views/DataSource/DataSourceSettings";
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
    }
  }

  @Builder DataSource() {
    Column() {
      Row() {
        Image($r('sys.symbol.play_circle_badge_music_note'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
        Text($r('app.string.data_source'))
          .fontSize(16)
          .fontColor(Color.White)
          .margin({ left: 12 })
        Blank()
        Image($r('sys.symbol.chevron_forward'))
          .width(16)
          .height(16)
          .fillColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.pushPage('DataSourceSettings', {})
      })
    }
    .backgroundColor($r('app.color.play_list_single_item_bg'))
    .borderRadius(12)
  }

  @Builder MultiDevice() {
    Column() {
      Row() {
        Image($r('sys.symbol.Interconnection_ic_multiscreen_collaboration'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
        Text($r('app.string.mission_continue'))
          .fontSize(16)
          .fontColor(Color.White)
          .margin({ left: 12 })
        Blank()
        Image($r('sys.symbol.chevron_forward'))
          .width(16)
          .height(16)
          .fillColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.pushPage('MissionContinueSettings', {})
      })
    }
    .backgroundColor($r('app.color.play_list_single_item_bg'))
    .borderRadius(12)
  }

  @Builder DisplaySettingsBuilder() {
    Column() {
      Row() {
        Image($r('sys.symbol.square_grid_2x2'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
        Text($r('app.string.display_settings'))
          .fontSize(16)
          .fontColor(Color.White)
          .margin({ left: 12 })
        Blank()
        Image($r('sys.symbol.chevron_forward'))
          .width(16)
          .height(16)
          .fillColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.pushPage('DisplaySettings', {})
      })
    }
    .backgroundColor($r('app.color.play_list_single_item_bg'))
    .borderRadius(12)
  }

  @Builder PlaybackSettingsBuilder() {
    Column() {
      Row() {
        Image($r('sys.symbol.play'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
        Text($r('app.string.playback_settings'))
          .fontSize(16)
          .fontColor(Color.White)
          .margin({ left: 12 })
        Blank()
        Image($r('sys.symbol.chevron_forward'))
          .width(16)
          .height(16)
          .fillColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.pushPage('PlaybackSettings', {})
      })
    }
    .backgroundColor($r('app.color.play_list_single_item_bg'))
    .borderRadius(12)
  }

  @Builder AboutApp() {
    Column() {
      Row() {
        Image($r('sys.symbol.bolt_lightbulb_max'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
        Text($r('app.string.open_first_start'))
          .fontSize(16)
          .fontColor(Color.White)
          .margin({ left: 12 })
        Blank()
        Image($r('sys.symbol.chevron_forward'))
          .width(16)
          .height(16)
          .fillColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        router.replaceUrl({
          url: 'pages/FirstOpenSubPages/FirstOpenPage'
        })
      })
      
      Row() {
        Image($r('sys.symbol.doc_plaintext_and_pencil'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
        Text($r('app.string.join_group'))
          .fontSize(16)
          .fontColor(Color.White)
          .margin({ left: 12 })
        Blank()
        Image($r('sys.symbol.chevron_forward'))
          .width(16)
          .height(16)
          .fillColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        promptAction.openToast({
          message: $r('app.string.opening_group')
        })
        startQQGroupAbility(getContext() as common.UIAbilityContext, 982093132)
      })
      .margin({ top: 8 })
      
      Row() {
        Image($r('sys.symbol.info_circle'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
        Text($r('app.string.about_this_app'))
          .fontSize(16)
          .fontColor(Color.White)
          .margin({ left: 12 })
        Blank()
        Image($r('sys.symbol.chevron_forward'))
          .width(16)
          .height(16)
          .fillColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.pushPage('AboutPage', {})
      })
      .margin({ top: 8 })
    }
    .backgroundColor($r('app.color.play_list_single_item_bg'))
    .borderRadius(12)
  }

  @Builder Main() {
    NavDestination() {
      Column() {
        Row() {
          Text($r('app.string.settings'))
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.Center)

        ArcList() {
          ArcListItem() {
            this.DataSource()
          }
          ArcListItem() {
            this.DisplaySettingsBuilder()
          }
          ArcListItem() {
            this.PlaybackSettingsBuilder()
          }
          ArcListItem() {
            this.MultiDevice()
          }
          ArcListItem() {
            this.AboutApp()
          }
          ArcListItem().height(12)
        }
        .padding({ left: 12, right: 12 })
        .layoutWeight(1)
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
