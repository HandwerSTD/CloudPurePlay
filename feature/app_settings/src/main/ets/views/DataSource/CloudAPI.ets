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

  build() {
    NavDestination() {
      CloudAPI_Console({
        LoginInfoSetter: (user, cookie) => {
          // UserManager.setUserInfo({
          //   data: {
          //     account: {
          //       userName: user.data.account.userName,
          //       id: user.data.account.id.toString(),
          //       vipType: user.data.account.vipType
          //     },
          //     profile: {
          //       userId: user.data.profile.userId.toString(),
          //       nickname: user.data.profile.nickname,
          //       backgroundUrl: user.data.profile.backgroundUrl,
          //       gender: user.data.profile.gender,
          //       avatarUrl: user.data.profile.avatarUrl
          //     }
          //   }
          // } as User, cookie)
          // UserManager.fetchAllUserData()
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
