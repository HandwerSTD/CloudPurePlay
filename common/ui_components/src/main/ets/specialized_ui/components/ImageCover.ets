@ComponentV2
export struct ImageCover {
  @Param @Require nowPlayingCoverImg: ResourceStr

  build() {
    Stack() {
      Image(this.nowPlayingCoverImg)
        .draggable(false)
        .ImageLightShadowFaker()
        .opacity(0.8)
        .brightness(1.3)
        .animation({ duration: 500 })

      Stack() {
        Image(this.nowPlayingCoverImg)
          .draggable(false)
          .ImageFaker()
          .animation({ duration: 500 })
      }.hitTestBehavior(HitTestMode.Transparent)
    }.alignContent(Alignment.TopStart)
  }
}
@Extend(Image) function ImageLightShadowFaker() {
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
  .brightness(1.3)
  .saturate(3)
  .translate({y: 24})
  .transition(TransitionEffect.OPACITY.animation({duration: 1000}))
}

@Extend(Image) function ImageFaker() {
  .aspectRatio(1)
  .layoutWeight(1)
  .constraintSize({
    maxWidth: '100%'
  })
  .borderRadius(20)
  .shadow(ShadowStyle.OUTER_DEFAULT_MD)
}

@ComponentV2
export struct ImageCoverThumbnail {
  @Param @Require nowPlayingCoverImg: ResourceStr
  @Param radius: number = 10

  build() {
    Stack({alignContent: Alignment.Center}) {
      Image(this.nowPlayingCoverImg)
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
      Image(this.nowPlayingCoverImg)
        .borderRadius(this.radius)
        .draggable(false)
        .shadow({
          radius: 2,
          color: '#11000000'
        })
        .ImageFaker()
        .borderRadius(this.radius)
    }
  }
}