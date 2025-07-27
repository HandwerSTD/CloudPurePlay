import { Logger, NowPlayingStore, ResponsiveUtil } from "@handwer/base"
import { hdsEffect } from "@kit.UIDesignKit"
import { curves } from "@kit.ArkUI"
import { cacheDownload } from "@kit.BasicServicesKit"
import { ClickUtil } from "@pura/harmony-utils"

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

  @Local nowPlayingCoverFaker: ResourceStr | undefined = undefined
  @Local nowPlayingCoverFakerUnder: ResourceStr | undefined = undefined
  @Local coverFakerVisibility: Visibility = Visibility.Visible
  coverFakerTransitionHandler: number | undefined = undefined
  @Local useCoverFaker: boolean = true

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
    // 初始化时，上封面下封面都显示真实封面
    this.nowPlayingCoverFaker = this.nowPlayingCoverImg
    this.nowPlayingCoverFakerUnder = this.nowPlayingCoverImg
    this.onImgChanged()
  }

  @Monitor('nowPlayingCoverImg')
  onPlayingCoverChanged() {
    // 如果已有正在切换的任务，进入快速切换模式一段时间，不再播放动画
    if (this.coverFakerTransitionHandler || !this.useCoverFaker) {
      clearTimeout(this.coverFakerTransitionHandler)
      this.coverFakerTransitionHandler = undefined
      this.getUIContext().animateTo({
        duration: 0
      }, () => {
        this.coverFakerVisibility = Visibility.Visible
        this.nowPlayingCoverFaker = this.nowPlayingCoverImg
        this.nowPlayingCoverFakerUnder = this.nowPlayingCoverImg
      })
      this.useCoverFaker = false
      ClickUtil.debounce(() => {
        this.useCoverFaker = true
      }, 2000, 'coverFakerDebounce')
      return
    }
    // 在真实封面发生切换时，先让下封面显示新真实封面
    this.nowPlayingCoverFakerUnder = this.nowPlayingCoverImg
    // 此时上封面还是旧真实封面，让其发生透明过渡
    this.getUIContext().animateTo({
      duration: 1000
    }, () => {
      this.coverFakerVisibility = Visibility.None
    })
    // 延迟一秒，待动画播完，切换（此时不可见的）上封面为真实封面，再切换为可见
    this.coverFakerTransitionHandler = setTimeout(() => {
      this.nowPlayingCoverFaker = this.nowPlayingCoverImg
      this.coverFakerVisibility = Visibility.Visible
      this.coverFakerTransitionHandler = undefined
    }, 1000)
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
        .transition(TransitionEffect.OPACITY.animation({duration: 1000}))


      Stack() {
        Image(this.nowPlayingCoverFakerUnder)
          .ImageFaker(() => {
            this.handleLike()
          })
        Image(this.nowPlayingCoverFaker)
          .ImageFaker(() => {
            this.handleLike()
          }, false)
          .opacity(this.coverFakerVisibility === Visibility.Visible ? 1 : 0 )
          .animation(this.useCoverFaker ? {duration: 1000} : undefined)
      }
    }.alignContent(Alignment.TopStart)
  }
}

@Extend(Image) function ImageFaker(handleLike: () => void, useShadow: boolean = true) {
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