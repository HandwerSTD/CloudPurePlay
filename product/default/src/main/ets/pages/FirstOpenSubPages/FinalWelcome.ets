import { LightUpLinedContainer } from "@handwer/ui_components";
import { ImageTitleWelcomeTemplate } from "./CommonTemplate";
import { hdsEffect } from "@kit.UIDesignKit";
import { ResponsiveUtil } from '@handwer/base'

@ComponentV2
export struct FinalWelcome {
  @Param @Require show: boolean
  @Param @Require onFinish: () => void

  @Local showFooter: boolean = false
  @Builder bottomButton() {
    if (this.showFooter) {
      LightUpLinedContainer({usePressShadow: false, lightNum: ResponsiveUtil.chooseByWidth([10, 12])}) {
        Button($r('app.string.start_use'))
          .width('100%')
          .onClick(() => {
            this.onFinish()
          })
          .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
            illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
          }).buildEffect())
          .transition(TransitionEffect.OPACITY.animation({duration: 500}))
      }
    }
  }
  build() {
    ImageTitleWelcomeTemplate({
      title: ' 欢迎来到《云净听》!',
      // subtitle: '',
      image: $r('app.media.layered_image'),
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