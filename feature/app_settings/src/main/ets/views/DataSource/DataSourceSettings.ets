import { CloudAPI_Console,
  INSTANCE_TYPE,
  LoginAPIUtils,
  NavidromeAPIConfigUtils, NavidromeRequestContext, User} from "@handwer/api_adapter"
import { UserManager, SCApp, Logger, ServiceInitUtils } from "@handwer/base"
import { CommonListItem, HDS_TITLE_CONFIG_STYLE, LightUpLinedContainer, LightUpLinedDefaultConfig, OverrideLightUpStat } from "@handwer/ui_components"
import { hdsEffect, HdsNavigation,
  HdsNavigationTitleMode, HdsNavigationAttribute } from "@kit.UIDesignKit"
import { DialogHelper } from "@pura/harmony-dialog"
import { generate_APIFinishWelcome_PageParams } from "./APIFinishWelcome"

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
  @Consumer(SCApp.settingsPageStack) pageStack: NavPathStack = new NavPathStack()
  @Local pageOpacity: number = 1

  @Local apiSourceAddr: string = ''
  @Local apiUserName: string = ''
  @Local apiPassword: string = ''

  @Local focusedInput: number = -1

  @Builder Main() {
    List({space: 12}) {
      ListItem().height($r('sys.float.ohos_id_navigation_bar_height'))
      ListItem() {
        Row() {
          LightUpLinedContainer({lightUpConfig: LightUpLinedDefaultConfig, overrideLightUpStat: this.focusedInput === 0 ? OverrideLightUpStat.ALWAYS_ENABLED : OverrideLightUpStat.ALWAYS_DISABLED}) {
            TextInput({placeholder: $r('app.string.api_source_addr'), text: this.apiSourceAddr!!})
              .type(InputType.URL)
              .TextInputEffect(0, (n) => this.focusedInput = n)
          }
        }.RowLightUpEffect()
      }
      ListItem() {
        Row() {
          LightUpLinedContainer({lightUpConfig: LightUpLinedDefaultConfig, overrideLightUpStat: this.focusedInput === 1 ? OverrideLightUpStat.ALWAYS_ENABLED : OverrideLightUpStat.ALWAYS_DISABLED}) {
            TextInput({placeholder: $r('app.string.api_username'), text: this.apiUserName!!})
              .type(InputType.USER_NAME)
              .TextInputEffect(1, (n) => this.focusedInput = n)
          }
        }.RowLightUpEffect()
      }
      ListItem() {
        Row() {
          LightUpLinedContainer({lightUpConfig: LightUpLinedDefaultConfig, overrideLightUpStat: this.focusedInput === 2 ? OverrideLightUpStat.ALWAYS_ENABLED : OverrideLightUpStat.ALWAYS_DISABLED}) {
            TextInput({placeholder: $r('app.string.api_password'), text: this.apiPassword!!})
              .type(InputType.Password)
              .TextInputEffect(2, (n) => this.focusedInput = n)
          }
        }.RowLightUpEffect()
      }
      ListItem() {
        LightUpLinedContainer() {
          Button($r('app.string.check_connectivity'))
            .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
              illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER,
            }))
            .width('100%')
            .onClick(() => {
              this.checkConnect()
            })
        }
      }
      ListItem().height(12)
    }.padding({left: 12, right: 12})
  }
  aboutToAppear(): void {
    const ctx = NavidromeAPIConfigUtils.getRequestContext()
    if (ctx) {
      this.apiSourceAddr = ctx.baseUrl;
      this.apiUserName = ctx.username;
      this.apiPassword = ctx.password ?? ''
    }
  }

  build() {
    NavDestination() {
      HdsNavigation() {
        this.Main()
      }.titleBar({
        style: HDS_TITLE_CONFIG_STYLE,
        content: {
          title: {
            mainTitle: 'Navidrome'
          }
        }
      })
      .titleMode(HdsNavigationTitleMode.MINI)
    }.hideTitleBar(true)
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

  checkConnect() {
    const contextBack = NavidromeAPIConfigUtils.getRequestContext()
    if (this.apiSourceAddr.endsWith('/')) {
      this.apiSourceAddr = this.apiSourceAddr.substring(0, this.apiSourceAddr.length - 1)
    }
    const newCtx = {
      baseUrl: this.apiSourceAddr,
      username: this.apiUserName,
      password: this.apiPassword
    } as NavidromeRequestContext
    NavidromeAPIConfigUtils.setRequestContext(newCtx)
    const id = DialogHelper.showLoadingDialog()
    NavidromeAPIConfigUtils.checkValidConnection({
      setChecking: (stat) => {
        if (!stat) {
          DialogHelper.closeDialog(id)
        }
      },
      setResult: (res) => {
        if (!res) {
          if (contextBack) NavidromeAPIConfigUtils.setRequestContext(contextBack)
          return;
        }

        LoginAPIUtils.getLoginStatus((val) => {
          Logger.debug(`NavidromeAPI`, `getLoginStat: ${JSON.stringify(val)}`)
          this.pageStack.pushPath({
            name: 'APIFinishWelcome',
            param: generate_APIFinishWelcome_PageParams(this.apiUserName, val.data.profile.avatarUrl, () => {
              const idd = DialogHelper.showLoadingDialog()
              ServiceInitUtils.reInit(INSTANCE_TYPE.NAVIDROME, val, newCtx.password!, newCtx)
                .finally(() => {
                  DialogHelper.closeDialog(idd)
                })
            })
          })
        }, INSTANCE_TYPE.NAVIDROME)
      }
    })
  }
}

@Extend(Row) function RowLightUpEffect() {
  .borderRadius(999)
    .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
      illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
    }).buildEffect())
}
@Extend(TextInput) function TextInputEffect(index: number, changeIndex: (stat: number) => void) {
  .fontColor(Color.White)
  .maxLines(1)
  .onFocus(() => {
    changeIndex(index)
  })
  .onBlur(() => {
    changeIndex(-1)
  })
  .padding(12)
}