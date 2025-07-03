import { ConfigUtils, LoginAPIUtils, RealIP_INITIAL, User } from '@handwer/cloud_api'
import { promptAction } from '@kit.ArkUI'

@Entry
@ComponentV2
struct Index {

  build() {
    Column() {
      TestComponent()
    }
    .height('100%')
    .width('100%')
  }
}

@ComponentV2
struct TestComponent {

  @Local qrImg: string = ''
  @Local qrKey: string = ''

  aboutToAppear(): void {
    ConfigUtils.setRequestContext({
      baseUrl: 'http://139.9.223.233:3000/',
      cookie: {},
      realIp: RealIP_INITIAL
    })
  }

  build() {
    Column() {
      if (this.qrImg !== '') {
        Image(this.qrImg)
          .width('50%')
        Text(`data = ${this.qrKey}`)
      }
      Button('进行二维码登录')
        .onClick(async () => {
          let str = await LoginAPIUtils.getQrCode()
          this.qrImg = str[1]; this.qrKey = str[0];
        })
      Button('检查登录情况')
        .onClick(async () => {
          const cookieSetter = (cookie: string) => {
            this.qrKey = cookie
          }
          const loginStatPersistent = (user: User) => {
            this.qrImg = user.data.profile.avatarUrl
            this.qrKey = user.data.profile.nickname
          }
          let result = await LoginAPIUtils.checkQrLogin(this.qrKey, cookieSetter, loginStatPersistent)

          promptAction.showToast({
            message: '登录' + (result ? '成功' : '失败')
          })
        })
      Button('登出')
        .onClick(async () => {
          let result = await LoginAPIUtils.logOut((user) => {
            this.qrImg = ''
            this.qrKey = ''
          })

          promptAction.showToast({
            message: '登出' + (result ? '成功' : '失败')
          })
        })

    }.width('100%').height('100%')
  }
}