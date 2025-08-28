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
  @Param useDefaultTextColor: boolean = false

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
              .fontColor(this.useDefaultTextColor ? $r('sys.color.font_primary') : Color.White)
            Text(this.subtitle)
              .fontColor(this.useDefaultTextColor ? $r('sys.color.font_primary') : Color.White)
          }
          .margin(24)

          Blank()
            .layoutWeight(1)

          Row() {
            if (this.footer) {
              this.footer()
            }
            if (this.useButtonFooter) {
              LightUpLinedContainer({usePressShadow: false, lightNum: ResponsiveUtil.chooseByWidth([10, 12])}) {
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
      .padding({bottom: 48, left: '20%', right: '20%'})
    }.width('100%').height('100%')
    .edgeEffect(EdgeEffect.Spring, {
      alwaysEnabled: false
    }).scrollBar(BarState.Off)
    .clip(false)
  }
}

@ComponentV2
export struct SymbolTitle {
  @Param @Require icon: Resource
  @Param iconSize: number = 50
  @Param @Require gradientColor: ResourceColor[]

  @Local snapshot: PixelMap | undefined = undefined

  @Local headerId: string | undefined = undefined

  aboutToAppear(): void {
    this.headerId = this.icon.id.toString()+Math.random().toPrecision(5).toString()
  }

  @Builder customHeader() {
    Stack() {
      Column() {
        SymbolGlyph(this.icon)
          .fontColor([Color.White])
          .fontWeight(FontWeight.Normal)
          .fontSize(this.iconSize)
      }
      .id(this.headerId)
      .width(100)
      .height(100)
      .justifyContent(FlexAlign.Center)
      .borderRadius(24)
      .linearGradient({
        angle: 135,
        colors: [[this.gradientColor[0], 0], [this.gradientColor[1], 1]]
      })
      .foregroundEffect({
        radius: 128
      })
      // .borderRadius(24)
      .brightness(1.1)
      .saturate(3)
      // .translate({y: 8})
      // .scale({x: 1.2, y: 1.2})

      Column() {
        SymbolGlyph(this.icon)
          .fontColor([Color.White])
          .fontWeight(FontWeight.Normal)
          .fontSize(this.iconSize)
      }
      .id(this.headerId)
      .width(100)
      .height(100)
      .justifyContent(FlexAlign.Center)
      .borderRadius(24)
      .linearGradient({
        angle: 135,
        colors: [[this.gradientColor[0], 0], [this.gradientColor[1], 1]]
      })
      .shadow(ShadowStyle.OUTER_FLOATING_SM)
    }
  }
  build() {
    this.customHeader()
  }
}

