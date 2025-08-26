import { ResponsiveUtil } from "@handwer/base"
import { LightUpLinedContainer } from "@handwer/ui_components"
import { hdsEffect } from "@kit.UIDesignKit"

@ComponentV2
export struct ImageTitleWelcomeTemplate {
  @Param image: Resource = $r('sys.symbol.questionmark_circle')
  @BuilderParam customImage?: () => void
  @Param @Require title: ResourceStr
  @Param subtitle: ResourceStr | undefined = undefined
  @BuilderParam footer: () => void
  @Param useButtonFooter: boolean = false
  @Param buttonFooterOnClick: () => void = () => {}
  @Param buttonFooterText: ResourceStr = ''

  build() {
    Scroll() {
      Column() {
        Column() {
          Column() {
            if (this.customImage) {
              this.customImage()
            } else {
              Image(this.image)
                .width(100)
                .height(100)
                .borderRadius(24)
                .shadow(ShadowStyle.OUTER_FLOATING_SM)
            }
          }
          .justifyContent(FlexAlign.Center)
          .padding(48)
          .height(ResponsiveUtil.PuraXOuterCheck() ? undefined : '40%')

          Column({space: 12}) {
            Text(this.title)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
            Text(this.subtitle)
              .fontColor(Color.White)
          }
          .margin(24)

          Blank()
            .layoutWeight(1)

          Row() {
            if (this.footer) {
              this.footer()
            }
            if (this.useButtonFooter) {
              LightUpLinedContainer({usePressShadow: false}) {
                Button(this.buttonFooterText)
                  .width('100%')
                  .onClick(() => {
                    this.buttonFooterOnClick()
                  })
                  .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
                    illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
                  }).buildEffect())
              }
            }
          }.margin(24).justifyContent(FlexAlign.Center)
        }
      }.visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
        illuminatedType: hdsEffect.PointLightIlluminatedType.CONTENT
      }).buildEffect())
    }.width('100%').height('100%')
    .edgeEffect(EdgeEffect.Spring, {
      alwaysEnabled: false
    }).scrollBar(BarState.Off)
  }
}