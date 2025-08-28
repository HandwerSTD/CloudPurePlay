import { ImageTitleWelcomeTemplate } from "./CommonTemplate";

@ComponentV2
export struct FinalWelcome {
  @Param @Require onFinish: () => void

  build() {
    ImageTitleWelcomeTemplate({
      title: ' 欢迎来到《云净听》!',
      // subtitle: '',
      image: $r('app.media.layered_image'),
      useButtonFooter: true,
      buttonFooterText: $r('app.string.start_use'),
      buttonFooterOnClick: () => {
        this.onFinish()
      }
    })
  }
}