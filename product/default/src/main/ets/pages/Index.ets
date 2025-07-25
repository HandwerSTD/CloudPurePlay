import { GlobalStore, Logger, PlayControl, PlayListOp, SCPref, SCUser, Settings,
  UserManager,
  UserSettings } from '@handwer/base'
import {
  AlbumAPIUtils,
  CloudAPIConfigUtils, LoginAPIUtils, RealIP_INITIAL, SongAPIUtils, User } from '@handwer/cloud_api'
import { PlayerUI } from '@handwer/player_ui'
import { promptAction } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'

const TAG = '[Index]'

@Entry
@ComponentV2
struct Index {
  gs = GlobalStore

  @Provider('consoleSheet') consoleSheet: boolean = false
  @Builder testConsole() {
    TestComponent()
  }

  build() {
    Column() {
      PlayerUI()
    }
    .bindSheet($$this.consoleSheet, this.testConsole, {
      preferType: SheetType.CENTER
    })
    .height('100%')
    .width('100%')
  }
}

@ComponentV2
struct TestComponent {

  @Local qrImg: string = ''
  @Local qrKey: string = ''

  @Local webSheet: boolean = false

  @Builder web() {
    WebLogin()
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
        .bindSheet($$this.webSheet, this.web())
      Button('进行二维码登录')
        .onClick(async () => {
          let str = await LoginAPIUtils.getQrCode()
          this.qrImg = str[1]; this.qrKey = str[0];
        })
      Button('检查登录情况')
        .onClick(async () => {
          const cookieSetter = (cookie: string) => {
            this.qrKey = cookie
            UserSettings.put(SCUser.cookie, cookie)
          }
          const loginStatPersistent = (user: User) => {
            this.qrImg = user.data.profile.avatarUrl
            this.qrKey = user.data.profile.nickname
            UserSettings.put(SCUser.user, user)
          }
          let result = await LoginAPIUtils.checkQrLogin(this.qrKey, cookieSetter, loginStatPersistent)

          promptAction.showToast({
            message: '登录' + (result ? '成功' : '失败')
          })
        })
      Button('搜索 Lose My Mind')
        .onClick(() => {
          SongAPIUtils.searchSongs('Lose My Mind', 0, )
            .then((res) => {
              Logger.debug(TAG, `search lose my mind = ${JSON.stringify(res)}`)

            })
        })
      Button('播放 F1 专辑')
        .onClick(() => {
          AlbumAPIUtils.getAlbumInfo(276211562)
            .then((res) => {
              PlayListOp.playListToQueue(res.songs, 0)
            })
        })

    }.width('100%').height('100%')
  }
}

/**
 * 网页登录页面
 */
@Component
export struct WebLogin {
  // @Consume('pageInfos') pageInfos: NavPathStack
  // @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @State userAgent: string = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
  @State isLoading: boolean = true
  controller: webview.WebviewController = new webview.WebviewController()
  menus: NavigationMenuItem[] = [
    {
      value: 'refresh',
      icon: $r('sys.symbol.route'),
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
        CloudAPIConfigUtils.setupCookie(cookie)
        let result = await LoginAPIUtils.getLoginStatus((user) => {
          UserManager.setUserInfo(user)
          UserSettings.put(SCUser.user, user)
          UserSettings.put(SCUser.cookie, cookie)
          Logger.debug(`Congrats!`)
        })
        return result
      } else {
        // ToastUtil.showToast('获取登录信息失败，请确认是否已在网页内登录！')
        return false
      }
    } catch (error) {
      // LogUtil.error('获取Cookie失败', error.message)
      // ToastUtil.showToast('获取Cookie失败：' + error.message)
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
      // LogUtil.error('检查 Cookie 有效性出错: ', error.message)
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
            // ToastUtil.showToast('登录成功!')
            // this.pageInfos.pop()
          }
          else {
            // ToastUtil.showToast('登录失败')
          }
        })
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .padding({ bottom: 10, left: 15, right: 15 })
  }
}