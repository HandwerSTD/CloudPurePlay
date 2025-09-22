import { NetImage } from "../../components/NetImage"
import { hdsEffect } from '@kit.UIDesignKit'

@ComponentV2
export struct ImageCover {
  @Param @Require nowPlayingCoverImg: ResourceStr

  build() {
    Stack() {
      NetImage({
        imageUrlI: this.nowPlayingCoverImg,
      })
        .aspectRatio(1)
        .layoutWeight(1)
        .constraintSize({
          maxWidth: '100%'
        })
        // .scale({x: 0.95, y: 0.95})
        .foregroundEffect({
          radius: 192
        })
        // .borderRadius(24)
        .brightness(1.4)
        .saturate(3)
        .translate({y: 24})
        .transition(TransitionEffect.OPACITY.animation({duration: 1000}))
        .draggable(false)
        .opacity(0.8)
        .animation({ duration: 500 })

      Stack() {
        NetImage({
          imageUrlI: this.nowPlayingCoverImg,
          customPlaceholder: $r('app.media.ff'),
          radius: 20
        })
          .borderRadius(20)
          .draggable(false)
          .aspectRatio(1)
          .layoutWeight(1)
          .constraintSize({
            maxWidth: '100%'
          })
          .shadow(ShadowStyle.OUTER_FLOATING_SM)
          .animation({ duration: 500 })
      }.hitTestBehavior(HitTestMode.Transparent)
    }.alignContent(Alignment.TopStart)
  }
}

@ComponentV2
export struct ImageCoverThumbnail {
  @Param @Require nowPlayingCoverImg: ResourceStr
  @Param useCoverShadow: boolean = false
  @Param radius: number = 10

  @Param name?: ResourceStr = undefined

  @Builder img() {
    NetImage({
      imageUrlI: this.nowPlayingCoverImg,
      radius: this.radius,
      lightedUp: hdsEffect.PointLightIlluminatedType.BORDER
    })
      .borderRadius(this.radius)
      .draggable(false)
      .shadow({
        radius: 2,
        color: '#11000000'
      })
      .aspectRatio(1)
      .layoutWeight(1)
      .constraintSize({
        maxWidth: '100%'
      })
      .clip(true)
      .shadow(ShadowStyle.OUTER_DEFAULT_MD)
      .borderRadius(this.radius)
      .clickEffect({
        level: ClickEffectLevel.HEAVY
      })
  }

  @Builder nameText() {
    if (this.name) {
      Text(this.name)
        .margin({top: 12}).maxLines(1).textOverflow({overflow: TextOverflow.Ellipsis})
        .wordBreak(WordBreak.BREAK_ALL)
        .fontSize(12).fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_on_primary'))
    }
  }

  @Builder IMG() {
    if (this.useCoverShadow) {
      Stack({alignContent: Alignment.Center}) {
        NetImage({
          imageUrlI: this.nowPlayingCoverImg
        })
          .aspectRatio(1)
          .layoutWeight(1)
          .constraintSize({
            maxWidth: '100%'
          })
          .draggable(false)
          .foregroundEffect({
            radius: 64
          })
          // .scale({x: 1.2, y: 1})
          // .translate({y: 10})
          .brightness(1.3)
          .saturate(3)
          .opacity(0.7)
        this.img()
      }
    } else {
      this.img()
    }
  }

  build() {
    if (this.name) {
      Column() {
        this.IMG()
        this.nameText()
      }
    } else {
      this.IMG()
    }
  }
}