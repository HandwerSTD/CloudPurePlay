import { NowPlayingStore, ResponsiveUtil } from "@handwer/base"
import { hdsEffect } from "@kit.UIDesignKit"
import { curves } from "@kit.ArkUI"
import { cacheDownload } from "@kit.BasicServicesKit"

const nps = NowPlayingStore

@ComponentV2
export struct ImageCover {
  @Param @Require nowPlayingCoverImg: ResourceStr
  @Param @Require handleLike: () => void = () => {}
  @Param useLight: boolean = false
  @Param useCoverAmbBreathe: boolean = false

  readonly lightOffset = 0
  readonly coverAmbDuration = 1500

  @Local pointLocation: number = 0
  @Local pointLightX: number = -this.lightOffset
  @Local pointLightY: number = -this.lightOffset
  @Local coverArea: Area | undefined = undefined
  pointLightMoveIntervalHandler?: number

  @Local coverAmbLightOpacity: number = 0.9
  coverAmbLightIntervalHandler?: number

  nowPlay = NowPlayingStore

  @Builder PointLight() {
    if (this.useLight) {
      Column() {}.height(20).width(20)
      .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
        options: {
          color: Color.White,
          intensity: 0.7,
          height: 150
        }
      }).buildEffect())
      .translate({
        x: this.pointLightX,
        y: this.pointLightY
      })
      .animation({duration: 2000})
    }
  }

  @Monitor('nowPlay.isPaused', 'nowPlay.isPlaying')
  onPlayStateChange() {
    if (this.nowPlay.isPlaying && !this.nowPlay.isPaused) {
      // 点光源移动
      if (this.useLight) {
        this.pointLightMoveIntervalHandler = setInterval(() => {
          this.pointLocation += 1;
          this.pointLocation %= 4;
          switch (this.pointLocation) {
            case 0:
              this.pointLightX = -this.lightOffset;
              this.pointLightY = -this.lightOffset;
              break;
            case 1:
              this.pointLightX = (this.coverArea!.width.valueOf() as number) //+ this.lightOffset
              break;
            case 2:
              this.pointLightY = (this.coverArea!.width.valueOf() as number) //+ this.lightOffset
              break;
            case 3:
              this.pointLightX = -this.lightOffset;
              break;
          }
        }, 2000)
      }
      // 封面发光呼吸效果
      if (this.useCoverAmbBreathe) {
        const cc = this.getUIContext()
        this.coverAmbLightIntervalHandler = setInterval(() => {
          if (this.coverAmbLightOpacity >= 0.7) {
            cc.animateTo({
              duration: this.coverAmbDuration,
              // curve: Curve.FastOutSlowIn
            }, () => {
              this.coverAmbLightOpacity = 0.4
            })
          } else {
            cc.animateTo({
              duration: this.coverAmbDuration,
              // curve: Curve.FastOutLinearIn
            }, () => {
              this.coverAmbLightOpacity = 0.9
            })
          }
        }, this.coverAmbDuration)
      }
    } else {
      clearInterval(this.pointLightMoveIntervalHandler)
      this.pointLightMoveIntervalHandler = undefined
      clearInterval(this.coverAmbLightIntervalHandler)
      this.coverAmbLightIntervalHandler = undefined
    }
  }
  relocatePointLight() {
    if (!this.useLight) return
    switch (this.pointLocation) {
      case 0:
        this.pointLightX = -this.lightOffset;
        this.pointLightY = -this.lightOffset;
        break;
      case 1:
        this.pointLightX = (this.coverArea!.width.valueOf() as number) + this.lightOffset
        break;
      case 2:
        this.pointLightY = (this.coverArea!.width.valueOf() as number) + this.lightOffset
        break;
      case 3:
        this.pointLightX = -this.lightOffset;
        break;
    }
  }

  @Monitor('nowPlayingCoverImg')
  onImgChanged() {
    if (typeof this.nowPlayingCoverImg === 'string') {
      try {
        cacheDownload.download(this.nowPlayingCoverImg as string, {})
      } catch (e) {}
    }
  }

  aboutToAppear(): void {
    this.onImgChanged()
  }

  build() {
    Stack() {
      this.PointLight()

      Image(this.nowPlayingCoverImg)
        .aspectRatio(1)
        .layoutWeight(nps.currentSong.id === 0 ? undefined : 1)
        .constraintSize({
          maxWidth: '100%'
        })
        // .scale({x: 0.95, y: 0.95})
        .foregroundEffect({
          radius: 192
        })
        .onAreaChange((_, area) => {
          this.coverArea = area
          this.relocatePointLight()
        })
        // .borderRadius(24)
        .opacity(this.coverAmbLightOpacity)
        .brightness(1.3)
        .saturate(3)
        .translate({y: 24})


      Image(this.nowPlayingCoverImg)
        .ImageFaker(() => {
          this.handleLike()
        })
    }.alignContent(Alignment.TopStart)
  }
}

@Extend(Image) function ImageFaker(handleLike: () => void) {
  .aspectRatio(1)
  .layoutWeight(nps.currentSong.id === 0 ? undefined : 1)
  .constraintSize({
    maxWidth: '100%'
  })
  .borderRadius(20)
  .shadow(ShadowStyle.OUTER_DEFAULT_MD)
  .margin(nps.isPaused ? ResponsiveUtil.chooseByWidth(['10%', '7%']) : 12)
  .animation({ curve:
  ResponsiveUtil.chooseByWidth(
    [curves.springMotion(0.8,0.4), curves.springMotion(0.6, 0.5)])
  })
  .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
    illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT
  }).buildEffect())
  .gesture(
    TapGesture({
      count: 2,
    }).onAction(() => {
      handleLike()
    })
  )
}