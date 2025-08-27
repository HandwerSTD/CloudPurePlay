import { GlobalContext, SCApp, SCGlobal } from "@handwer/base";
import { CommonListItem, HDS_TITLE_CONFIG_STYLE, LightUpLinedContainer, SnackBarUtils } from "@handwer/ui_components";
import { HdsNavigation, HdsNavigationTitleMode, HdsNavigationAttribute } from "@hms.hds.hdsBaseComponent";
import { hdsEffect, HdsSnackBar } from "@kit.UIDesignKit";
import { common, OpenLinkOptions } from '@kit.AbilityKit';
import {  DataSourceSettings } from "../views/DataSource/DataSourceSettings";
import { AboutPage } from "../views/AboutPage";
import { APIFinishWelcome } from "../views/DataSource/APIFinishWelcome";
import { CloudAPI_Source } from "../views/DataSource/CloudAPI";
import { NavidromeAPI_Source } from "../views/DataSource/NavidromeAPI";
import { MissionContinueSettings } from "../views/MissionContinue/MissionContinueSettings";
import { DisplaySettings } from "../views/DisplaySettings/DisplaySettings";
import { PlaybackSettings } from "../views/PlaybackSettings/PlaybackSettings";

@ComponentV2
export struct MainPage {
  @Param onOuterPop: (() => void) | undefined = undefined
  snack = new HdsSnackBar(this.getUIContext())
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
      LightUpLinedContainer({ lightUpConfig: {lightIntensity: 1, lightHeight: 120 }}) {
        CommonListItem({
          icon: $r('sys.symbol.play_circle_badge_music_note'),
          title: $r('app.string.data_source'),
        }).onClick(() => {
          this.pushPage('DataSourceSettings', {})
        })
      }
    }.backgroundColor($r('app.color.play_list_single_item_bg'))
    .borderRadius(20)
    .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
      illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
    }).buildEffect())
  }

  @Builder MultiDevice() {
    Column() {
      LightUpLinedContainer({ lightUpConfig: {lightIntensity: 1, lightHeight: 120 }}) {
        CommonListItem({
          icon: $r('sys.symbol.Interconnection_ic_multiscreen_collaboration'),
          title: $r('app.string.mission_continue'),
        }).onClick(() => {
          this.pushPage('MissionContinueSettings', {})
        })
      }
    }.backgroundColor($r('app.color.play_list_single_item_bg'))
    .borderRadius(20)
    .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
      illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
    }).buildEffect())
  }

  @Builder DisplaySettingsBuilder() {
    Column() {
      LightUpLinedContainer({ lightUpConfig: {lightIntensity: 1, lightHeight: 120 }}) {
        CommonListItem({
          icon: $r('sys.symbol.square_grid_2x2'),
          title: $r('app.string.display_settings'),
        }).onClick(() => {
          this.pushPage('DisplaySettings', {})
        })
      }
    }.backgroundColor($r('app.color.play_list_single_item_bg'))
    .borderRadius(20)
    .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
      illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
    }).buildEffect())
  }

  @Builder PlaybackSettingsBuilder() {
    Column() {
      LightUpLinedContainer({ lightUpConfig: {lightIntensity: 1, lightHeight: 120 }}) {
        CommonListItem({
          icon: $r('sys.symbol.play'),
          title: $r('app.string.playback_settings'),
        }).onClick(() => {
          this.pushPage('PlaybackSettings', {})
        })
      }
    }.backgroundColor($r('app.color.play_list_single_item_bg'))
    .borderRadius(20)
    .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
      illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
    }).buildEffect())
  }

  @Builder AboutApp() {
    Column() {
      LightUpLinedContainer({ lightUpConfig: {lightIntensity: 1, lightHeight: 120 }}) {
        CommonListItem({
          icon: $r('sys.symbol.doc_plaintext_and_pencil'),
          title: $r('app.string.join_group'),
        })
          .onClick(() => {
            SnackBarUtils.showMessage(this.snack, $r('sys.symbol.doc_plaintext_and_pencil'), $r('app.string.opening_group'))
            startQQGroupAbility(getContext() as common.UIAbilityContext, 982093132)
          })
      }
      LightUpLinedContainer({ lightUpConfig: {lightIntensity: 1, lightHeight: 120 }}) {
        CommonListItem({
          icon: $r('sys.symbol.info_circle'),
          title: $r('app.string.about_this_app'),
        })
          .onClick(() => {
            this.pushPage('AboutPage', {})
          })
      }
    }.backgroundColor($r('app.color.play_list_single_item_bg'))
    .borderRadius(20)
    .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
      illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
    }).buildEffect())

  }

  @Builder Main() {
    NavDestination() {
      HdsNavigation() {
        Column() {
          List({space: 12}) {
            ListItem().height($r('sys.float.ohos_id_navigation_bar_height'))
            ListItem() {
              this.DataSource()
            }
            ListItem() {
              this.DisplaySettingsBuilder()
            }
            ListItem() {
              this.PlaybackSettingsBuilder()
            }
            ListItem() {
              this.MultiDevice()
            }
            ListItem() {
              this.AboutApp()
            }
            ListItem().height(12)
          }.padding({left: 12, right: 12})
        }
        .width('100%').height('100%')
      }.titleBar({
        style: HDS_TITLE_CONFIG_STYLE,
        content: {
          title: {
            mainTitle: $r('app.string.settings')
          }
        }
      })
      .titleMode(HdsNavigationTitleMode.MINI)
    }.onBackPressed(() => {
      this.consoleSheet = false
      return true
    }).hideTitleBar(true).backgroundColor(Color.Transparent)
    .onShown(() => {
      // 由于在 aboutToAppear 里连续 push 两个，Main 的 onShown 根本不会执行，所以它被首次调用的时候就一定是该 pop 的时候
      if (this.quickJump) {
        this.onOuterPop?.()
      }
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