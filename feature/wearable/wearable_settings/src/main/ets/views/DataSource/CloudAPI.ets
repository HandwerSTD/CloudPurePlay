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
      Column() {
        // Title Bar
        Row() {
          Image($r('sys.symbol.chevron_backward'))
            .width(24)
            .height(24)
            .fillColor(Color.White)
            .onClick(() => {
              this.pageStack.pop()
            })
          Text('CloudAPI')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .margin({ left: 12 })
          Blank()
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })

        CloudAPI_Console({
          LoginInfoSetter: (user, cookie) => {
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
                }, InstanceSwitcher.getInstanceNameByType(INSTANCE_TYPE.CLOUD))
              })
            }, INSTANCE_TYPE.CLOUD)
          }
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .opacity(this.pageOpacity)
    .animation({ duration: 300 })
  }
}
