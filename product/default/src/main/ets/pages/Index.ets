import { GlobalStore, Logger, PlayControl, PlayListOp } from '@handwer/base'
import {
  AlbumAPIUtils,
  CloudAPIConfigUtils, LoginAPIUtils, RealIP_INITIAL, SongAPIUtils, User } from '@handwer/cloud_api'
import { PlayerUI } from '@handwer/player_ui'
import { promptAction } from '@kit.ArkUI'

const TAG = '[Index]'

@Entry
@ComponentV2
struct Index {
  gs = GlobalStore

  @Local consoleSheet: boolean = false
  @Builder testConsole() {
    TestComponent()
  }

  build() {
    Column() {
      Button('console')
        .onClick(() => {
          this.consoleSheet = !this.consoleSheet
        })
        .bindSheet($$this.consoleSheet, this.testConsole)
      PlayerUI()
    }
    .height('100%')
    .width('100%')
    .padding({
      top: this.gs.wd.top,
      bottom: this.gs.wd.bottom
    })
  }
}

@ComponentV2
struct TestComponent {

  @Local qrImg: string = ''
  @Local qrKey: string = ''

  aboutToAppear(): void {
    CloudAPIConfigUtils.setRequestContext({
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
      Button('搜索 Lose My Mind')
        .onClick(() => {
          SongAPIUtils.searchSongs('Lose My Mind', 0, )
            .then((res) => {
              Logger.debug(TAG, `search lose my mind = ${res}`)

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