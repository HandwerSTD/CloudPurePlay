import { ImageTitleWelcomeTemplate } from "./CommonTemplate";

@ComponentV2
export struct FinalWelcome {
  @Param @Require onFinish: () => void


  @Builder customFooter() {
    Column({space: 12}) {
      Text('在设置中可以重新进入新手引导页面')
        .fontSize(12)
        .fontColor($r('sys.color.ohos_id_color_text_hint'))

      Button('开始使用')
        .width('100%')
        .onClick(() => {
          this.onFinish()
        })
    }
  }

  build() {
    ImageTitleWelcomeTemplate({
      title: ' 欢迎来到《云净听》!',
      subtitle: '一站式表情包管理新体验',
      image: $r('app.media.layered_image'),
      footer: () => { this.customFooter() }
    })
  }
}