import { CloudAPI_Console, User } from "@handwer/api_adapter";
import { SCApp, UserManager, UserSettings, SCUser } from "@handwer/base";
import { CommonListItem, HDS_TITLE_CONFIG_STYLE, LightUpLinedContainer, SnackBarUtils } from "@handwer/ui_components";
import { HdsNavigation, HdsNavigationAttribute, HdsNavigationTitleMode } from "@hms.hds.hdsBaseComponent";
import { hdsEffect, HdsSnackBar } from "@kit.UIDesignKit";
import { common, OpenLinkOptions } from '@kit.AbilityKit';
import { DataSourceSettings } from "../views/DataSourceSettings";
import { AboutPage } from "../views/AboutPage";

@ComponentV2
export struct MainPage {
  snack = new HdsSnackBar(this.getUIContext())
  @Consumer(SCApp.settingsSheet) consoleSheet: boolean = false
  @Provider(SCApp.settingsPageStack) pageStack: NavPathStack = new NavPathStack()
  @Local pageOpacity: number = 1

  aboutToAppear(): void {
    this.pageStack.pushPathByName('Main', [], false)
  }

  @Builder pageMap(name: string) {
    if (name === 'DataSourceSettings') {
      DataSourceSettings()
    } else if (name === 'Main') {
      this.Main()
    } else if (name === 'AboutPage') {
      AboutPage()
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