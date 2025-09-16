import {
  CloudAPIConfigUtils,
  Cloud_RequestContext,
  CloudAPI_Console,
  LoginAPIUtils,
  INSTANCE_TYPE,
  InstanceSwitcher
} from "@handwer/api_adapter"
import { SCApp, Logger, ServiceInitUtils } from "@handwer/base"
import { DialogHelper } from "@pura/harmony-dialog"
import { generate_APIFinishWelcome_PageParams } from "./APIFinishWelcome"

@ComponentV2
export struct CloudAPI_Source {
  @Consumer(SCApp.settingsPageStack) pageStack: NavPathStack = new NavPathStack()

  @Local pageOpacity: number = 1

  aboutToAppear(): void {
    const context = CloudAPIConfigUtils.getRequestContext() ?? {
      baseUrl: 'http://111.229.38.178:3333/',
      cookie: {
      },
    } as Cloud_RequestContext
    CloudAPIConfigUtils.setRequestContext(context)
  }

  loginInfoSetter(cookie: string) {
    const context = CloudAPIConfigUtils.getRequestContext() ?? {
      baseUrl: 'http://111.229.38.178:3333/',
      cookie: {
        cookie: cookie,
      },
    } as Cloud_RequestContext
    CloudAPIConfigUtils.setRequestContext(context)
    LoginAPIUtils.getLoginStatus((val) => {
      Logger.debug(`NavidromeAPI`, `getLoginStat: ${JSON.stringify(val)}`)
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
    NavDestination() {
      CloudAPI_Console({
        LoginInfoSetter: (user, cookie) => {
          this.loginInfoSetter(cookie)
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
    .onReady((ctx) => {
      if (ctx.pathInfo.param) {
        // 优先加载传参过来的Config
        const req = ((ctx.pathInfo.param) as Record<string, Object>)['context'] as Cloud_RequestContext
        if (req && req.cookie && req.cookie.cookie) {
          this.loginInfoSetter(req.cookie.cookie!)
        }
      }
    })
    .opacity(this.pageOpacity)
    .animation({duration: 300})
  }
}
