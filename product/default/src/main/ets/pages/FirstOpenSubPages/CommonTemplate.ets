import { ResponsiveUtil } from "@ohos/base"

@ComponentV2
export struct ImageTitleWelcomeTemplate {
  @Param image: Resource = $r('sys.symbol.questionmark_circle')
  @BuilderParam customImage?: () => void
  @Param @Require title: ResourceStr
  @Param subtitle: ResourceStr | undefined = undefined
  @BuilderParam footer: () => void

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
            Text(this.subtitle)
          }
          .margin(24)

          Blank()
            .layoutWeight(1)

          Row() {
            if (this.footer) {
              this.footer()
            }
          }.margin(24).justifyContent(FlexAlign.Center)
        }
      }
    }.width('100%').height('100%')
    .edgeEffect(EdgeEffect.Spring, {
      alwaysEnabled: false
    }).scrollBar(BarState.Off)
  }
}