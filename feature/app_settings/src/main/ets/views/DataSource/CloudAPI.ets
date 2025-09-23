import {
  CloudAPIConfigUtils,
  Cloud_RequestContext,
  CloudAPI_Console,
  LoginAPIUtils,
  INSTANCE_TYPE,
  InstanceSwitcher,
  RealIP_INITIAL
} from "@handwer/api_adapter"
import { SCApp, Logger, ServiceInitUtils } from "@handwer/base"
import { HDS_TITLE_CONFIG_STYLE, LightUpLinedContainer, OverrideLightUpStat } from "@handwer/ui_components"
import { DialogHelper } from "@pura/harmony-dialog"
import { generate_APIFinishWelcome_PageParams } from "./APIFinishWelcome"
import { hdsEffect, HdsNavDestination, HdsNavDestinationAttribute } from "@kit.UIDesignKit"
import { promptAction } from "@kit.ArkUI"

@ComponentV2
export struct CloudAPI_Source {
  @Consumer(SCApp.settingsPageStack) pageStack: NavPathStack = new NavPathStack()

  @Local pageOpacity: number = 1
  @Local focusedInput: number = 0
  @Local apiAddr: string = ''


  aboutToAppear(): void {
    const context = CloudAPIConfigUtils.getRequestContext() ?? {
      baseUrl: this.apiAddr,
      cookie: {
      },
      realIp: {
        toggle: false,
        realIp: ''
      }
    } as Cloud_RequestContext
    CloudAPIConfigUtils.setRequestContext(context)
    this.apiAddr = context.baseUrl ?? ''
  }

  loginInfoSetter(cookie: string) {
    if (!this.apiAddr || this.apiAddr == '') {
      promptAction.openToast({
        message: '请填写合法的 API 地址后再试'
      })
      return
    }
    if (this.apiAddr.endsWith('/')) {
      this.apiAddr = this.apiAddr.substring(0, this.apiAddr.length - 1)
    }
    if (!this.apiAddr.startsWith('http://') && !this.apiAddr.startsWith('https://')) {
      this.apiAddr = 'http://' + this.apiAddr
    }
    const context: Cloud_RequestContext = {
      baseUrl: this.apiAddr,
      cookie: {
        cookie: cookie,
        customCookie: undefined
      },
      realIp: {
        toggle: false,
        realIp: ''
      }
    }
    CloudAPIConfigUtils.setRequestContext(context)
    LoginAPIUtils.getLoginStatus((val) => {
      Logger.debug(`CloudAPI`, `getLoginStat: ${JSON.stringify(val)}`)
      this.pageStack.pushPath({
        name: 'APIFinishWelcome',
        param: generate_APIFinishWelcome_PageParams(val.data.profile.nickname, val.data.profile.avatarUrl, () => {
          const idd = DialogHelper.showLoadingDialog()
          ServiceInitUtils.reInit(INSTANCE_TYPE.CLOUD, val, cookie, context)
            .finally(() => {
              DialogHelper.closeDialog(idd)
            })
        },InstanceSwitcher.getInstanceNameByType(INSTANCE_TYPE.CLOUD))
      })
    }, INSTANCE_TYPE.CLOUD)
  }

  build() {
    HdsNavDestination() {
      Column() {
        Blank().height(12)
        Row() {
          LightUpLinedContainer({ overrideLightUpStat: this.focusedInput === 1 ? OverrideLightUpStat.ALWAYS_ENABLED : OverrideLightUpStat.ALWAYS_DISABLED}) {
            TextInput({placeholder: $r('app.string.api_source_addr'), text: this.apiAddr!!})
              .type(InputType.USER_NAME)
              .TextInputEffect(1, (n) => this.focusedInput = n)
          }
        }.RowLightUpEffect()
        CloudAPI_Console({
          LoginInfoSetter: (cookie) => {
            this.loginInfoSetter(cookie)
          }
        })
      }.padding({left: 12, right: 12, top: $r('sys.float.ohos_id_navigation_bar_height')})
    }.titleBar({
      content: {
        title: {
          mainTitle: 'CloudAPI'
        }
      },
      style: HDS_TITLE_CONFIG_STYLE
    })
    .backgroundColor(Color.Transparent)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .onReady((ctx) => {
      if (ctx.pathInfo.param) {
        // 优先加载传参过来的Config
        const req = ((ctx.pathInfo.param) as Record<string, Object>)['context'] as Cloud_RequestContext
        if (req && req.cookie && req.cookie.cookie) {
          this.apiAddr = req.baseUrl
          this.loginInfoSetter(req.cookie.cookie!)
        }
      }
    })
    .opacity(this.pageOpacity)
    .animation({duration: 300})
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
  .placeholderColor(Color.White)
  .maxLines(1)
  .onFocus(() => {
    changeIndex(index)
  })
  .onBlur(() => {
    changeIndex(-1)
  })
  .padding(12)
}