import { WantUtil } from "@pura/harmony-utils"
import { ImageTitleWelcomeTemplate } from "./CommonTemplate"

@ComponentV2
export struct OpenWelcome {
  @Param @Require setResult: (val: boolean) => void
  @Param @Require showedFlow: boolean

  @Builder footer() {
    Row() {
      Toggle({ type: ToggleType.Checkbox })
        .size({ width: 20, height: 20 })// .selectedColor($r('app.color.accent'))
        .onChange((isOn: boolean) => {
          this.setResult(isOn)
        })
      Text() {
        Span('我已阅读并同意\n')// .fontColor($r('app.color.text_level2'))
          .fontSize(16)
          .fontColor(this.showedFlow ? Color.White : undefined)
        Span('《关于云净听和隐私的声明》')// .fontColor($r('app.color.accent'))
          .fontColor($r('app.color.SkyBlue'))
          .fontSize(16)
          .onClick(() => {
            WantUtil.toWebBrowser('https://agreement-drcn.hispace.dbankcloud.cn/index.html?lang=zh&agreementId=1765356433194391488')
          })
      }
    }
  }

  build() {
    Column() {
      ImageTitleWelcomeTemplate({
        title: ' 欢迎！',
        subtitle: '《云净听》| 音乐播放器',
        image: $r('app.media.app_background'),
        useDefaultTextColor: !this.showedFlow,
        footer: () => { this.footer() }
      })
    }.width('100%').height('100%')
  }
}