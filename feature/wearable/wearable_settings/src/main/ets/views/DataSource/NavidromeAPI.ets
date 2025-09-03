import {
  NavidromeAPIConfigUtils,
  NavidromeRequestContext,
  LoginAPIUtils,
  INSTANCE_TYPE,
  InstanceSwitcher
} from "@handwer/api_adapter"
import { SCApp, Logger, ServiceInitUtils, GlobalStore } from "@handwer/base"
import { ArcConst } from "@handwer/wearable_ui_components"
import { ArcList,ArcListAttribute, ArcListItem,ArcListItemAttribute, promptAction } from "@kit.ArkUI"
import { DialogHelper } from "@pura/harmony-dialog"
import { generate_APIFinishWelcome_PageParams } from "./APIFinishWelcome"

@ComponentV2
export struct NavidromeAPI_Source {
  @Consumer(SCApp.settingsPageStack) pageStack: NavPathStack = new NavPathStack()
  @Local pageOpacity: number = 1

  @Local apiSourceAddr: string = ''
  @Local apiUserName: string = ''
  @Local apiPassword: string = ''
  @Local focusedInput: number = -1

  @Builder Main() {
    ArcList() {
      ArcListItem() {
        Column() {
          TextInput({ placeholder: $r('app.string.api_source_addr'), text: this.apiSourceAddr })
            .type(InputType.URL)
            .fontColor(Color.White)
            .placeholderColor($r('sys.color.font_secondary'))
            .maxLines(1)
            .backgroundColor($r('app.color.play_list_single_item_bg'))
            .borderRadius('50%')
            .padding(16)
            .onChange((value: string) => {
              this.apiSourceAddr = value
            })
            .onFocus(() => {
              this.focusedInput = 0
            })
            .onBlur(() => {
              this.focusedInput = -1
            })
        }
      }
      .width(ArcConst.ARC_LIST_W)
      ArcListItem() {
        Column() {
          TextInput({ placeholder: $r('app.string.api_username'), text: this.apiUserName })
            .type(InputType.USER_NAME)
            .fontColor(Color.White)
            .placeholderColor($r('sys.color.font_secondary'))
            .maxLines(1)
            .backgroundColor($r('app.color.play_list_single_item_bg'))
            .borderRadius('50%')
            .padding(16)
            .onChange((value: string) => {
              this.apiUserName = value
            })
            .onFocus(() => {
              this.focusedInput = 1
            })
            .onBlur(() => {
              this.focusedInput = -1
            })
        }
      }
      .width(ArcConst.ARC_LIST_W)
      ArcListItem() {
        Column() {
          TextInput({ placeholder: $r('app.string.api_password'), text: this.apiPassword })
            .type(InputType.Password)
            .fontColor(Color.White)
            .placeholderColor($r('sys.color.font_secondary'))
            .maxLines(1)
            .backgroundColor($r('app.color.play_list_single_item_bg'))
            .borderRadius('50%')
            .padding(16)
            .onChange((value: string) => {
              this.apiPassword = value
            })
            .onFocus(() => {
              this.focusedInput = 2
            })
            .onBlur(() => {
              this.focusedInput = -1
            })
        }
      }
      .width(ArcConst.ARC_LIST_W)
      ArcListItem() {
        Button($r('app.string.check_connectivity'))
          .width('100%')
          .backgroundColor($r('sys.color.brand'))
          .fontColor(Color.White)
          .onClick(() => {
            this.checkConnect()
          })
      }
      .width(ArcConst.ARC_LIST_W)
    }.space(ArcConst.ARC_LIST_SPC)
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
      Column() {
        this.Main()
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
    .animation({ duration: 300 })
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
          promptAction.openToast({
            message: $r('app.string.connect_server_failed')
          })
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
