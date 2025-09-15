import {  LightUpLongButton } from "@handwer/ui_components";
import { ImageTitleWelcomeTemplate } from "./CommonTemplate";

@ComponentV2
export struct FinalWelcome {
  @Param @Require show: boolean
  @Param @Require onFinish: () => void

  @Local showFooter: boolean = false
  @Builder bottomButton() {
    if (this.showFooter) {
      LightUpLongButton({
        title: $r('app.string.first_open_page_start_use'),
        icon: $r('sys.symbol.checkmark'),
        clickAction: () => {
          this.onFinish()
        },
      })
    }
  }
  build() {
    ImageTitleWelcomeTemplate({
      title: $r('app.string.first_open_page_final_welcome_title'),
      // subtitle: '',
      image: $r('app.media.ff'),
      footer: () => {
        this.bottomButton()
      }
    }).transition(TransitionEffect.OPACITY.animation({duration: 1000, delay: 1000}).combine(TransitionEffect.scale({
      x: 1.2, y: 1.2
    }).animation({duration: 1000, curve: Curve.EaseInOut, delay: 1000})))
      .onAppear(() => {
        setTimeout(() => {
          this.showFooter = true
        }, 1000)
      })
  }
}