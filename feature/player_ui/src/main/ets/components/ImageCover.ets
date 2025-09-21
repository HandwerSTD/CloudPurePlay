import { ImgCache, Logger, NowPlayingStore, PlayQueueUtils, ResponsiveUtil } from "@handwer/base"
import { hdsEffect } from "@kit.UIDesignKit"
import { curves } from "@kit.ArkUI"
import { cacheDownload } from "@kit.BasicServicesKit"
import { ClickUtil } from "@pura/harmony-utils"
import { AlbumCoverColorUtils } from "../utils/AlbumCoverColorUtils"
import { BgFlowController } from "@handwer/ui_components"

const nps = NowPlayingStore

@ComponentV2
export struct ImageCover {
  @Param @Require nowPlayingCoverImg: string
  @Param @Require handleLike: () => void = () => {}
  @Param useLight: boolean = false
  @Param useCoverAmbBreathe: boolean = false

  readonly lightOffset = 0
  @Local pointLocation: number = 0
  @Local pointLightX: number = -this.lightOffset
  @Local pointLightY: number = -this.lightOffset
  @Local coverArea: Area | undefined = undefined
  pointLightMoveIntervalHandler?: number

  @Local coverAmbLightOpacity: number = 1

  @Local nowPlayingCoverFaker: string | undefined = undefined
  @Local nowPlayingCoverFakerUnder: string | undefined = undefined
  @Local coverFakerVisibility: Visibility = Visibility.Visible
  coverFakerTransitionHandler: number | undefined = undefined
  @Local useCoverFaker: boolean = true

  // 预留接口，封面打光可以亮起，暂时没找到合适的交互
  @Local onCoverAmbLightUp: boolean = false

  nowPlay = NowPlayingStore

  @Builder PointLight() {
    if (this.useLight) {
      Column() {}.height(20).width(20)
      .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
        options: {
          color: Color.White,
          intensity: 0.7,
          height: 200
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
    } else {
      clearInterval(this.pointLightMoveIntervalHandler)
      this.pointLightMoveIntervalHandler = undefined
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
        ImgCache.cache(this.nowPlayingCoverImg)
      } catch (e) {}
      // 预加载下一个封面
      try {
        const nxtPic = PlayQueueUtils.peekNextSong()?.picUrl
        if (nxtPic) ImgCache.cache(nxtPic)
      } catch (e) {
        Logger.warn(`preload next cover pic failed: ${JSON.stringify(e)}`)
      }
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
    // 此时上封面还是旧真实封面，让其发生透明过渡；关闭光效
    this.getUIContext().animateTo({
      duration: 1000
    }, () => {
      this.coverFakerVisibility = Visibility.None
      this.coverAmbLightOpacity = 0
    })
    // 延迟一秒，待动画播完，切换（此时不可见的）上封面为真实封面，再切换为可见
    this.coverFakerTransitionHandler = setTimeout(() => {
      this.nowPlayingCoverFaker = this.nowPlayingCoverImg
      this.coverFakerVisibility = Visibility.Visible
      this.coverFakerTransitionHandler = undefined
      this.coverAmbLightOpacity = 0.9
    }, 1000)
  }

  build() {
    Stack() {
      this.PointLight()

      Image(ImgCache.proxy(this.nowPlayingCoverFaker as string))
        .draggable(false)
        .onAreaChange((_, area) => {
          this.coverArea = area
          this.relocatePointLight()
        })
        .ImageLightShadowFaker()
        .opacity(this.coverAmbLightOpacity)
        .animation({duration: 1000, curve: Curve.Ease})
        .brightness(this.onCoverAmbLightUp ? 1.6 : 1.3)
        .animation({duration: 500})


      Stack() {
        Image(ImgCache.proxy(this.nowPlayingCoverFakerUnder as string))
          .draggable(false)
          .id('coverFakerUnder')
          .ImageFaker(() => {
            this.handleLike()
          })
          .onComplete(() => {
            ClickUtil.debounce(async () => {
              const colors = await AlbumCoverColorUtils.getCoverColor()
              // Logger.debug(`colors = ${JSON.stringify(colors)}`)
              BgFlowController.getInstance().changeColor(colors)
            }, 1000)
          })
        Image(ImgCache.proxy(this.nowPlayingCoverFaker as string))
          .draggable(false)
          .ImageFaker(() => {
            this.handleLike()
          }, false)
          .opacity(this.coverFakerVisibility === Visibility.Visible ? 1 : 0 )
          .animation(this.useCoverFaker ? {duration: 1000} : undefined)
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

@Extend(Image) function ImageFaker(handleLike: () => void, useShadow: boolean = true) {
  .aspectRatio(1)
  .layoutWeight(nps.currentSong.id === "0" ? undefined : 1)
  .constraintSize({
    maxWidth: '100%'
  })
  .borderRadius(20)
  .shadow(useShadow ? ShadowStyle.OUTER_DEFAULT_MD : undefined)
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

@ComponentV2
export struct ImageCoverThumbnail {
  @Param @Require nowPlayingCoverImg: string
  @Param radius: number = 10

  build() {
    Stack({alignContent: Alignment.Center}) {
      Image(ImgCache.proxy(this.nowPlayingCoverImg))
        .aspectRatio(1)
        .layoutWeight(nps.currentSong.id === "0" ? undefined : 1)
        .margin(nps.isPaused ? ResponsiveUtil.chooseByWidth(['10%', '7%']) : 12)
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
        .id('coverUnder_Thumbnail')
        .borderRadius(this.radius)
        .draggable(false)
        .shadow({
          radius: 2,
          color: '#11000000'
        })
        .ImageFaker(() => {
        })
        .borderRadius(this.radius)
        .onComplete(() => {
          ClickUtil.debounce(async () => {
            const colors = await AlbumCoverColorUtils.getCoverColor('coverUnder_Thumbnail')
            // Logger.debug(`colors = ${JSON.stringify(colors)}`)
            BgFlowController.getInstance().changeColor(colors)
          }, 500)
        })
    }
  }
}