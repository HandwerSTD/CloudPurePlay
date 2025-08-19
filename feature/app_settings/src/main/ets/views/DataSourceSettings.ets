import { CloudAPI_Console, InstanceSwitcher, INSTANCE_TYPE,
  LoginAPIUtils,
  NavidromeAPIConfigUtils,
  NavidromeRequestContext,
  User,
  User_INITIAL} from "@handwer/api_adapter"
import { UserManager, UserSettings, SCUser, Logger, SCApp, ServiceInitUtils } from "@handwer/base"
import { CommonListItem, HDS_TITLE_CONFIG_STYLE, LightUpLinedContainer } from "@handwer/ui_components"
import { hdsEffect, HdsNavigationAttribute, HdsNavigation,
  HdsNavigationTitleMode } from "@kit.UIDesignKit"

@ComponentV2
export struct DataSourceSettings {
  @Local pageOpacity: number = 1
  @Consumer(SCApp.settingsPageStack) pageStack: NavPathStack = new NavPathStack()

  @Builder CloudAPI() {
    ListItem() {
      Column() {
        LightUpLinedContainer({ lightUpConfig: {lightIntensity: 1, lightHeight: 120 }}) {
          CommonListItem({
            icon: $r('sys.symbol.play_circle_badge_music_note'),
            title: 'CloudAPI',
          }).onClick(() => {
            this.pushPage('CloudAPI_Source', {})
          })
        }
      }.backgroundColor($r('app.color.play_list_single_item_bg'))
      .borderRadius(20)
      .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
        illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
      }).buildEffect())
    }
  }

  @Builder NavidromeAPI() {
    ListItem() {
      Column() {
        LightUpLinedContainer({ lightUpConfig: {lightIntensity: 1, lightHeight: 120 }}) {
          CommonListItem({
            icon: $r('sys.symbol.play_circle_badge_music_note'),
            title: 'NavidromeAPI',
          }).onClick(() => {
            this.pushPage('NavidromeAPI_Source', {})
          })
        }
      }.backgroundColor($r('app.color.play_list_single_item_bg'))
      .borderRadius(20)
      .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
        illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
      }).buildEffect())
    }
  }

  build() {
    NavDestination() {
      HdsNavigation() {
        Column() {
          List({space: 12}) {
            ListItem().height($r('sys.float.ohos_id_navigation_bar_height'))
            this.CloudAPI()
            this.NavidromeAPI()
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
    }.backgroundColor(Color.Transparent)
    .hideTitleBar(true)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .opacity(this.pageOpacity)
    .animation({duration: 300})
  }

  pushPage(name: string, params: Record<string, Object>) {
    this.pageStack.pushPathByName(name, params, true)
  }
}

@ComponentV2
export struct CloudAPI_Source {
  @Local pageOpacity: number = 1

  build() {
    NavDestination() {
      CloudAPI_Console({
        LoginInfoSetter: (user, cookie) => {
          UserManager.setUserInfo({
            data: {
              account: {
                userName: user.data.account.userName,
                id: user.data.account.id.toString(),
                vipType: user.data.account.vipType
              },
              profile: {
                userId: user.data.profile.userId.toString(),
                nickname: user.data.profile.nickname,
                backgroundUrl: user.data.profile.backgroundUrl,
                gender: user.data.profile.gender,
                avatarUrl: user.data.profile.avatarUrl
              }
            }
          } as User, cookie)
          UserManager.fetchAllUserData()
        }
      })
    }.title('CloudAPI')
    .backgroundColor(Color.Transparent)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .opacity(this.pageOpacity)
    .animation({duration: 300})
  }
}

@ComponentV2
export struct NavidromeAPI_Source {
  @Local pageOpacity: number = 1

  build() {
    NavDestination() {
      Button('set config')
        .onClick(() => {
          const ctx = {
            baseUrl: "http://192.168.1.13:4533/",
            username: "handwer",
            password: '123456',
          } as NavidromeRequestContext
          NavidromeAPIConfigUtils.setRequestContext(ctx)
          NavidromeAPIConfigUtils.checkValidConnection({
            setChecking: (val) => {
              Logger.debug(`NavidromeAPI`, `set checking = ${val}`)
            },
            setResult: (val) => {
              Logger.debug(`NavidromeAPI`, `set result = ${val}`)
              if (val) {
                LoginAPIUtils.getLoginStatus((val) => {
                  if (val.data.account.id === '') return;
                  Logger.debug(`NavidromeAPI`, `getLoginStat: ${JSON.stringify(val)}`)
                  ServiceInitUtils.reInit(INSTANCE_TYPE.NAVIDROME, val, ctx.password!, ctx)
                }, INSTANCE_TYPE.NAVIDROME)
              }
            }
          })
        })
    }.title('NavidromeAPI')
    .backgroundColor(Color.Transparent)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .opacity(this.pageOpacity)
    .animation({duration: 300})
  }
}