import { CloudAPIConfigUtils, CloudAPI_User, LoginAPIUtils, RealIP_INITIAL } from "@handwer/cloud_api"
import { webview } from "@kit.ArkWeb"
import { promptAction } from "@kit.ArkUI"
import { LogUtil } from "@pura/harmony-utils"
import { INSTANCE_TYPE } from "../../../../../../Index"

@ComponentV2
export struct CloudAPI_Console {
  @Param @Require LoginInfoSetter: (cookie: string) => void

  @Local qrImg: string = ''
  @Local qrKey: string = ''

  @Local webSheet: boolean = false

  @Builder web() {
    WebLogin({
      closeSheet: () => {
        this.webSheet = false
      },
      LoginInfoSetter: (cookie) => {
        this.LoginInfoSetter(cookie)
      }
    })
  }

  build() {
    Column() {
      if (this.qrImg !== '') {
        Image(this.qrImg)
          .width('50%')
        Text(`data = ${this.qrKey}`)
      }
      Button('网页登录')
        .onClick(() => {
          this.webSheet = true
        })
        .bindSheet($$this.webSheet, this.web(), {
          showClose: false
        })
    }.width('100%').height('100%')
  }
}

/**
 * 网页登录页面
 */
@ComponentV2
export struct WebLogin {
  @Event closeSheet: () => void
  @Param @Require LoginInfoSetter: (cookie: string) => void
  @Local userAgent: string = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
  @Local isLoading: boolean = true
  controller: webview.WebviewController = new webview.WebviewController()
  menus: NavigationMenuItem[] = [
    {
      value: 'refresh',
      icon: $r('sys.symbol.circle'),
      action: () => {
        this.controller.removeCache(true)
        this.loadUrl() }
    }
  ]

  private loadUrl() {
    this.controller.setCustomUserAgent(this.userAgent)
    this.controller.loadUrl('https://music.163.com/#/login/')
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          this.Bar()
          Stack() {
            Web({
              src: '',
              controller: this.controller
            })
              .allowWindowOpenMethod(true)
              .databaseAccess(true)
              .horizontalScrollBarAccess(true)
              .verticalScrollBarAccess(true)
              .fileAccess(true)
              .domStorageAccess(true)
              .javaScriptAccess(true)
              .imageAccess(true)
              .onlineImageAccess(true)
              .overScrollMode(OverScrollMode.ALWAYS)
              .width('100%')
              .height('100%')
              .onProgressChange((e) => {
                if (e.newProgress == 100) {
                  this.isLoading = false
                }
              })
              .onControllerAttached(() => {
                try {
                  this.loadUrl()
                } catch (error) {
                  console.error('Login Web Error: ' + error.message)
                }
              })

            if(this.isLoading) {
              Stack({ alignContent: Alignment.Center }) {
                this.Loading()
              }
              .height('100%')
              .width('100%')
            }
          }
          .width('100%')
          .height('100%')
        }
        .height('100%')
        .width('100%')
      }
      .height('100%')
      .width('100%')
      .backgroundColor($r('app.color.background'))
    }
    .menus(this.menus)
    .title('登录')
    .backgroundColor($r('app.color.background'))
  }

  async getCookie(): Promise<boolean> {
    try {
      let cookie = webview.WebCookieManager.fetchCookieSync('https://music.163.com')
      if (await this.checkValidCookie(cookie)) {
        cookie = cookie + '; OS=pc'
        this.LoginInfoSetter(cookie)
        promptAction.showToast({
          message: '登陆成功！'
        })
        return true
      } else {
        promptAction.showToast({
          message: '获取登录信息失败，请确认是否已在网页内登录！'
        })
        return false
      }
    } catch (error) {
      LogUtil.error('获取Cookie失败', error.message)
      // ToastUtil.showToast('获取Cookie失败：' + error.message)
      promptAction.showToast({
        message: '获取登录信息失败: '+error.message
      })
      return false
    }
  }

  async checkValidCookie(cookie: string): Promise<boolean> {
    try {
      const hasMusicU = cookie.includes('MUSIC_U')
      const hasCsrf = cookie.includes('__csrf')

      if (hasMusicU && hasCsrf) {
        return true
      } else {
        return false
      }
    } catch (error) {
      LogUtil.error('检查 Cookie 有效性出错: ', error.message)
      return false
    }
  }

  @Builder
  Loading() {
    Column() {
      LoadingProgress()
        .width(40)
      Text('网页加载中')
        .fontColor($r('app.color.reverse'))
    }
    .backgroundColor(Color.Transparent)
    .padding({ left: 15, right: 15, bottom: 10, top: 10})
  }
  @Builder
  Bar() {
    Row() {
      Button() {
        Row({ space: 5 }) {
          Image($r('sys.symbol.quick_help')).fillColor($r('app.color.reverse')).height('80%')
          Text('如何登录?').fontColor($r('app.color.reverse')).height('80%')
        }
        .padding({ right: 10 })
      }
      .height(30)
      .alignSelf(ItemAlign.End)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        // DialogUtil.showConfirmDialog({
        //   title: '如何登录',
        //   message: MsgConstants.HOW_TO_LOGIN_MSG
        // })
      })
      Row({ space: 10 }) {
        Button('获取登录信息').onClick(async () => {
          let result = await this.getCookie()
          if(result) {
            this.closeSheet()
          }
          else {
          }
        })
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .padding({ bottom: 10, left: 15, right: 15 })
  }
}