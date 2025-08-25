import {
  NavidromeAPIConfigUtils,
  NavidromeRequestContext,
  LoginAPIUtils,
  INSTANCE_TYPE,
  InstanceSwitcher
} from "@handwer/api_adapter"
import { SCApp, Logger, ServiceInitUtils } from "@handwer/base"
import {
  LightUpLinedContainer,
  LightUpLinedDefaultConfig,
  OverrideLightUpStat,
  HDS_TITLE_CONFIG_STYLE
} from "@handwer/ui_components"
import { DialogHelper } from "@pura/harmony-dialog"
import { generate_APIFinishWelcome_PageParams } from "./APIFinishWelcome"
import { HdsNavigation, HdsNavigationTitleMode, hdsEffect, HdsNavigationAttribute } from "@kit.UIDesignKit"

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
    .onReady((ctx) => {
      if (ctx.pathInfo.param) {
        const req = ((ctx.pathInfo.param) as Record<string, Object>)['context'] as NavidromeRequestContext
        if (req) {
          this.apiSourceAddr = req.baseUrl
          this.apiPassword = req.password ?? ''
          this.apiUserName = req.username
        }
      }
    })
    .opacity(this.pageOpacity)
    .animation({duration: 300})
  }

  checkConnect() {
    const contextBack = NavidromeAPIConfigUtils.getRequestContext()
    if (this.apiSourceAddr.endsWith('/')) {
      this.apiSourceAddr = this.apiSourceAddr.substring(0, this.apiSourceAddr.length - 1)
    }
    if (!this.apiSourceAddr.startsWith('http://') && !this.apiSourceAddr.startsWith('https://')) {
      this.apiSourceAddr = 'http://' + this.apiSourceAddr
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
            }, InstanceSwitcher.getInstanceNameByType(INSTANCE_TYPE.NAVIDROME))
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