import { Logger, NowPlayingStore, PlayQueueUtils } from "@handwer/base"
import { curves } from "@kit.ArkUI"
import { cacheDownload } from "@kit.BasicServicesKit"
import { ClickUtil } from "@pura/harmony-utils"
import { AlbumCoverColorUtils } from "../utils/AlbumCoverColorUtils"

const nps = NowPlayingStore

@ComponentV2
export struct WearableImageCover {
  @Param @Require nowPlayingCoverImg: ResourceStr
  @Param useLight: boolean = false
  @Param useCoverAmbBreathe: boolean = false
  @Event resetNewBackgroundColor: (colors: ResourceColor[]) => void


  @Local coverAmbLightOpacity: number = 1

  @Local nowPlayingCoverFaker: ResourceStr | undefined = undefined
  @Local nowPlayingCoverFakerUnder: ResourceStr | undefined = undefined
  @Local coverFakerVisibility: Visibility = Visibility.Visible
  coverFakerTransitionHandler: number | undefined = undefined
  @Local useCoverFaker: boolean = true

  nowPlay = NowPlayingStore

  @Monitor('nowPlayingCoverImg')
  onImgChanged() {
    if (typeof this.nowPlayingCoverImg === 'string') {
      try {
        cacheDownload.download(this.nowPlayingCoverImg as string, {})
      } catch (e) {}
      // 预加载下一个封面
      try {
        const nxtPic = PlayQueueUtils.peekNextSong()?.picUrl
        if (nxtPic) cacheDownload.download(nxtPic, {})
      } catch (e) {
        Logger.warn(`preload next cover pic failed: ${JSON.stringify(e)}`)
      }
    }
  }

  aboutToAppear(): void {
    this.nowPlayingCoverFaker = this.nowPlayingCoverImg
    this.nowPlayingCoverFakerUnder = this.nowPlayingCoverImg
    this.onImgChanged()
  }

  @Monitor('nowPlayingCoverImg')
  onPlayingCoverChanged() {
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
      }, 1500, 'coverFakerDebounce') // 缩短debounce时间
      return
    }

    this.nowPlayingCoverFakerUnder = this.nowPlayingCoverImg
    this.getUIContext().animateTo({
      duration: 800 // 稍微缩短动画时间
    }, () => {
      this.coverFakerVisibility = Visibility.None
      this.coverAmbLightOpacity = 0
    })

    this.coverFakerTransitionHandler = setTimeout(() => {
      this.nowPlayingCoverFaker = this.nowPlayingCoverImg
      this.coverFakerVisibility = Visibility.Visible
      this.coverFakerTransitionHandler = undefined
      this.coverAmbLightOpacity = 0.8 // 稍微降低光强度
    }, 800)
  }

  build() {
    Stack() {

      Image(this.nowPlayingCoverFaker)
        .draggable(false)
        .ImageLightShadowFaker()
        .opacity(this.coverAmbLightOpacity)
        .animation({duration: 800, curve: Curve.Ease})
        .brightness(1.2) // 稍微降低亮度

      Stack() {
        Image(this.nowPlayingCoverFakerUnder)
          .draggable(false)
          .id('coverFakerUnder')
          .ImageFaker(() => {
          })
          .onComplete(() => {
            ClickUtil.debounce(async () => {
              const colors = await AlbumCoverColorUtils.getCoverColor()
              this.resetNewBackgroundColor(colors)
            }, 1500) // 缩短debounce时间
          })
        Image(this.nowPlayingCoverFaker)
          .draggable(false)
          .ImageFaker(() => {
          }, false)
          .opacity(this.coverFakerVisibility === Visibility.Visible ? 1 : 0 )
          .animation(this.useCoverFaker ? {duration: 800} : undefined)
      }.hitTestBehavior(HitTestMode.Transparent)
    }.alignContent(Alignment.TopStart)
  }
}

@Extend(Image) function ImageLightShadowFaker() {
  .aspectRatio(1)
  .layoutWeight(nps.currentSong.id === "0" ? undefined : 1)
  .constraintSize({
    maxWidth: '100%'
  })
  .foregroundEffect({
    radius: 96 // 手表屏幕较小，降低模糊半径
  })
  .brightness(1.2)
  .saturate(2.5) // 稍微降低饱和度
  .translate({y: 12}) // 减少阴影偏移
  .transition(TransitionEffect.OPACITY.animation({duration: 800}))
}

@Extend(Image) function ImageFaker(handleLike: () => void, useShadow: boolean = true) {
  .aspectRatio(1)
  .layoutWeight(nps.currentSong.id === "0" ? undefined : 1)
  .constraintSize({
    maxWidth: '100%'
  })
  .borderRadius(16) // 手表上使用较小的圆角
  .shadow(useShadow ? ShadowStyle.OUTER_DEFAULT_SM : undefined) // 使用较小的阴影
  .animation({ curve: curves.springMotion(0.7, 0.4) })
  .gesture(
    TapGesture({
      count: 2,
    }).onAction(() => {
      handleLike()
    })
  )
}

@ComponentV2
export struct WearableImageCoverThumbnail {
  @Param @Require nowPlayingCoverImg: ResourceStr
  @Param radius: number = 8 // 手表上使用较小的圆角

  build() {
    Stack({alignContent: Alignment.Center}) {
      Image(this.nowPlayingCoverImg)
        .aspectRatio(1)
        .layoutWeight(nps.currentSong.id === "0" ? undefined : 1)
        .margin(nps.isPaused ? 6 : 4) // 手表上使用较小的边距
        .constraintSize({
          maxWidth: '100%'
        })
        .draggable(false)
        .foregroundEffect({
          radius: 32 // 手表屏幕较小，降低模糊半径
        })
        .brightness(1.2)
        .saturate(2.5)
        .opacity(0.6)
      Image(this.nowPlayingCoverImg)
        .borderRadius(this.radius)
        .draggable(false)
        .shadow({
          radius: 1,
          color: '#11000000'
        })
        .ImageFaker(() => {
        })
        .borderRadius(this.radius)
    }
  }
}
