import { FeaturedPlayUtils, GlobalStore, Logger, NowPlayingStore, PlayControl,
  PlayQueueStore,
  PlayQueueUtils,
  ResponsiveUtil,
  SCApp,
  SongConvertUtils,
  SongLike,
  UserStore } from "@handwer/base"
import { PLAYMODE, SongAPIUtils, Song_INITIAL } from "@handwer/api_adapter"
import { LightUpRoundedButton, LightUpConfig, OverrideLightUpStat, LightUpBorderRoundButton, SnackBarUtils,
  UIComponentUtils } from "@handwer/ui_components"
import { ColorMetrics, curves, LengthMetrics, SymbolGlyphModifier } from "@kit.ArkUI"
import { ClickUtil, DateUtil } from "@pura/harmony-utils"
import { HdsActionBar, ActionBarButton, ActionBarStyle, hdsEffect, HdsSnackBar } from "@kit.UIDesignKit"
import { cacheDownload } from "@kit.BasicServicesKit"
import { LyricComponent } from "./LyricArea"
import { ImageCover } from "../components/ImageCover"
import { PlayQueueView, PlayQueueViewBuilder } from "./PlayQueueView"

const nps = NowPlayingStore
const LIGHT_TOP_BTN_SM: LightUpConfig = {
  lightIntensity: 3,
  lightHeight: 200,
  lightBloom: 0
}
const LIGHT_TOP_BTN_MD: LightUpConfig = {
  lightIntensity: 3,
  lightHeight: 200,
  lightBloom: 0
}
const LIGHT_TOP_BTN_LG: LightUpConfig = {
  lightIntensity: 3,
  lightHeight: 200,
  lightBloom: 0
}

const LIGHT_PLAYBACK_BTN_MD: LightUpConfig = {
  lightIntensity: 0.8,
  lightHeight: 300,
  lightBloom: 0,
}

const LIGHT_PLAYBACK_BTN_LG: LightUpConfig = {
  lightIntensity: 0.8,
  lightHeight: 300,
  lightBloom: 0,
}

@ComponentV2
export struct MainPage {
  hdsSnackBar = new HdsSnackBar(this.getUIContext())
  gs = GlobalStore
  user = UserStore

  _nps = NowPlayingStore

  @Consumer('consoleSheet') consoleSheet: boolean = false
  @Provider(SCApp.playQueueSheet) showQueueSheet: boolean = false

  controller: hdsEffect.ShaderEffectController = new hdsEffect.ShaderEffectController()

  get nowPlayingCoverImg() {
    if (nps.currentSong === Song_INITIAL) {
      return $r('sys.media.Celia')
    } else {
      return nps.playMode === PLAYMODE.LOCAL ? nps.currentPic : nps.currentPic + '?param=512y512'
    }
  }
  get topAreaExpandShouldHideNormal() {
    return this.isTopAreaExpand && ResponsiveUtil.widthCheck(['xs','sm', 'md'])
  }
  get todayIcon() {
    return UIComponentUtils.getTodayIcon()
  }
  get isThisSongLiked() {
    return nps.isLiked
  }
  @Local sliderThickness: number = 10
  @Local isMovingSlider: boolean = false
  @Local sliderMovingTime: number = 0
  @Local shouldShowSlider: boolean = false
  shouldShowSliderTimeoutHandler?: number

  @Local backgroundFlowingColors: ResourceColor[] = []

  @Local isTopAreaExpand: boolean = false

  @Local isBottomAreaExpand: boolean = false

  // ----------------------------------------


  @Builder BottomAreaControlButton_ActionBar_PrimaryButton() {
    LightUpRoundedButton({
      lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_TOP_BTN_SM, LIGHT_TOP_BTN_MD, LIGHT_TOP_BTN_LG]),
      icon: $r('sys.symbol.AI_play'),
      customBgColor: $r('sys.color.icon_fourth'),
      clickAction: () => {
        this.isBottomAreaExpand = !this.isBottomAreaExpand
      },
      overrideLightUpStat: this.isBottomAreaExpand ? OverrideLightUpStat.ALWAYS_ENABLED : OverrideLightUpStat.NO_OVERRIDE,
      customFontColor: this.isBottomAreaExpand ? [Color.Black] : [Color.White, Color.White]
    })
  }
  @Builder BottomAreaControlButton_ActionBar() {
    Row() {
      HdsActionBar({
        isExpand: this.isBottomAreaExpand!!,
        primaryButtonBuilder: () => {
          this.BottomAreaControlButton_ActionBar_PrimaryButton()
        },
        primaryButtonBuilderWidth: LengthMetrics.vp(40),
        startButtons: [
          new ActionBarButton({
            baseIcon: nps.isLiked ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'),
            baseIconSymbolGlyphModifier: nps.isLiked ? new SymbolGlyphModifier().fontColor([Color.Red]) : undefined,
            width: LengthMetrics.vp(40),
            onClick: () => {
              SongLike.likeThisSong((icon, msg) => {
                SnackBarUtils.showMessage(this.hdsSnackBar, icon, msg)
              })
            },
          }),
          new ActionBarButton({
            baseIcon: UIComponentUtils.getQueueCycleModeIcon(PlayQueueStore.cycleMode),
            width: LengthMetrics.vp(40),
            onClick: () => {
              PlayQueueUtils.changeCycleMode()
            }
          }),
          new ActionBarButton({
            baseIcon: $r('sys.symbol.list_interrupt'),
            width: LengthMetrics.vp(40)
          }),
        ]
      })
        .hitTestBehavior(this.isTopAreaExpand ? HitTestMode.Default : HitTestMode.Transparent)
        .offset(this.isBottomAreaExpand ? undefined : {x: 5}) // 抵消掉自带边距
    }.hitTestBehavior(this.isTopAreaExpand ? HitTestMode.Default : HitTestMode.Transparent)
  }

  @Builder TopAreaActionButton_ActionBar_PrimaryButton() {
    LightUpRoundedButton({
      lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_TOP_BTN_SM, LIGHT_TOP_BTN_MD, LIGHT_TOP_BTN_LG]),
      icon: $r('sys.symbol.star_planet'),
      customBgColor: $r('sys.color.icon_fourth'),
      clickAction: () => {
        this.isTopAreaExpand = !this.isTopAreaExpand
      },
      overrideLightUpStat: this.isTopAreaExpand ? OverrideLightUpStat.ALWAYS_ENABLED : OverrideLightUpStat.NO_OVERRIDE,
      customFontColor: this.isTopAreaExpand ? [Color.Black] : [Color.White, Color.White]
    })
  }
  // TODO：长按调整模式
  @Builder TopAreaActionButton_ActionBar() {
    Row() {
      HdsActionBar({
        isExpand: this.isTopAreaExpand!!,
        primaryButtonBuilder: () => {
          this.TopAreaActionButton_ActionBar_PrimaryButton()
        },
        primaryButtonBuilderWidth: LengthMetrics.vp(40),
        endButtons: [
          new ActionBarButton({
            baseIcon: $r('sys.symbol.opticaldisc_badge_heart'),
            width: LengthMetrics.vp(40),
            backgroundColor: nps.isHeartMode ? ColorMetrics.numeric(0xFFFFFFFF) : undefined,
            baseIconSymbolGlyphModifier: nps.isHeartMode ? new SymbolGlyphModifier().fontColor([Color.Black]) : undefined,
            onClick: () => {
              FeaturedPlayUtils.playHeartMode((icon, msg) => {
                SnackBarUtils.showMessage(this.hdsSnackBar, icon, msg)
              })
            }
          }),
          new ActionBarButton({
            baseIcon: this.todayIcon,
            width: LengthMetrics.vp(40),
            backgroundColor: nps.isDailyListMode ? ColorMetrics.numeric(0xFFFFFFFF) : undefined,
            baseIconSymbolGlyphModifier: nps.isDailyListMode ? new SymbolGlyphModifier().fontColor([Color.Black]) : undefined,
            onClick: () => {
              FeaturedPlayUtils.playDailySongs((icon, msg) => {
                SnackBarUtils.showMessage(this.hdsSnackBar, icon, msg)
              }, this.todayIcon)
            }
          }),
          new ActionBarButton({
            baseIcon: $r('sys.symbol.radio'),
            width: LengthMetrics.vp(40),
            baseIconSymbolGlyphModifier: nps.isPersonalFM ? new SymbolGlyphModifier().fontColor([Color.Black]) : undefined,
            backgroundColor: nps.isPersonalFM ? ColorMetrics.numeric(0xFFFFFFFF) : undefined,
            onClick: () => {
              FeaturedPlayUtils.playPersonalizedFM()
            }
          }),
          new ActionBarButton({
            baseIcon: $r('sys.symbol.house'),
            width: LengthMetrics.vp(40)
          }),
        ]
      })
        .hitTestBehavior(this.isTopAreaExpand ? HitTestMode.Default : HitTestMode.Transparent)
        .offset(!this.topAreaExpandShouldHideNormal ? {x: -5} : undefined) // 这东西自带一个+5的边距，给它抵消掉
    }.hitTestBehavior(this.isTopAreaExpand ? HitTestMode.Default : HitTestMode.Transparent)
  }
  @Builder TopAreaActionButton_Normal() {
    Row({space: 24}) {
      // Discover
      Blank().width(40)

      // Settings
      LightUpRoundedButton({
        lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_TOP_BTN_SM, LIGHT_TOP_BTN_MD, LIGHT_TOP_BTN_LG]),
        icon: $r('sys.symbol.gearshape'),
        customBgColor: $r('sys.color.icon_fourth'),
        clickAction: () => {
          this.consoleSheet = !this.consoleSheet
        },
        customFontColor: [Color.White, Color.White]
      }).visibility(this.topAreaExpandShouldHideNormal ? Visibility.Hidden : Visibility.Visible)
        .transition(TransitionEffect.OPACITY.animation({duration: 200}))
    }.width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder TopArea() {
    Stack() {
      this.TopAreaActionButton_Normal()
      this.TopAreaActionButton_ActionBar()
    }.width('100%')
    .padding(this.topAreaExpandShouldHideNormal ? {} : {left: 24, right: 24})
    .alignContent(this.topAreaExpandShouldHideNormal ? Alignment.Center : Alignment.Start)
    .animation({curve: curves.springMotion()})
  }

  @Builder AuthorInfo() {
    Column() {
      Text(nps.currentSong.name)
        .width('90%')
        .textAlign(TextAlign.Start)
        .textOverflow({
          overflow: TextOverflow.MARQUEE
        })
        .marqueeOptions({
          start: true,
          fadeout: true
        })
        .fontColor(Color.White).fontWeight(FontWeight.Bold)
        .fontSize(24)
      Text(nps.currentArtists)
        .width('90%')
        .textAlign(TextAlign.Start)
        .textOverflow({
          overflow: TextOverflow.MARQUEE
        })
        .marqueeOptions({
          start: true,
          fadeout: true
        })
        .fontColor(Color.White)
    }.visibility(this.isBottomAreaExpand ? Visibility.Hidden : Visibility.Visible)
    .padding({right: 40}) // 避让右边按钮
    .transition(TransitionEffect.OPACITY.animation({duration: 200}))
    .alignItems(HorizontalAlign.Start)
    .bindSheet(this.showQueueSheet!!, PlayQueueViewBuilder, {
      showClose: false,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      preferType: SheetType.SIDE,
      blurStyle: BlurStyle.BACKGROUND_REGULAR,
      backgroundColor: $r('app.color.ui_sheet_bg_col')
    })
    .onClick(() => {
      this.showQueueSheet = !this.showQueueSheet
    })
  }

  @Builder CoverInfo() {
    Column() {
      Row() {
        ImageCover({
          nowPlayingCoverImg: this.nowPlayingCoverImg,
          handleLike: () => {
            this.handleLike()
          },
          useLight: true,
          useCoverAmbBreathe: false,
          resetNewBackgroundColor: (colors) => {
            this.backgroundFlowingColors = colors.map((val) => val.color)
            Logger.debug(`try resetting flow colors: `, this.backgroundFlowingColors.toString())
            this.controller.setEffectParams({
              colorSource: this.backgroundFlowingColors
            },)
            this.controller.play()
          }
        })
      }.layoutWeight(1)
      // Blank().height(24)
      Stack(){
        this.AuthorInfo()
        this.BottomAreaControlButton_ActionBar() // 这东西自带 margin，所以上下边距就不用要了
      }//.width('100%').padding(this.isBottomAreaExpand ? undefined : {right: 24})
      .alignContent(this.isBottomAreaExpand ? Alignment.Center : Alignment.End)
      .animation({curve: curves.springMotion()})
      // Blank().height(24)

      this.ProgressBar('90%')
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    // .aspectRatio(1)
    .constraintSize({
      minWidth: 0,
      maxWidth: '100%',
      minHeight: 0,
      maxHeight: ResponsiveUtil.widthCheck(['sm', 'md']) ? '100%' : 500
    })
    .onClick(() => {
      this.showProgressBar()
    })
  }

  @Builder ProgressBar(wid: Dimension) {
    Column() {
      // 进度条
      Slider({
        value: nps.playTime,
        min: 0,
        max: nps.currentSong.duration,
        step: 1,
        style: SliderStyle.InSet
      })
        .width('100%')
        .blockColor(Color.Transparent)
        .trackColor('#aaffffff')
        .trackThickness(this.sliderThickness)
        .selectedColor(Color.White)
        .showSteps(false)
        .showTips(false)
        .onChange(this.handleSliderChange)
        .hitTestBehavior(!this.shouldShowSlider ? HitTestMode.None : HitTestMode.Default)

      Row() {
        // 当前时间
        Row(){
          Text(`${SongConvertUtils.changeDuration(nps.playTime)}`)
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .fontColor(Color.White)
            .alignSelf(ItemAlign.Start)
          if (this.isMovingSlider) {
            Text(' ')
              .transition(TransitionEffect.OPACITY.animation({
                duration: 300
              }))
              .fontSize(12)
              .textAlign(TextAlign.Start)
              .fontColor(Color.White)
              .alignSelf(ItemAlign.Start)
            SymbolGlyph($r('sys.symbol.arrow_right'))
              .transition(TransitionEffect.OPACITY.animation({
                duration: 300
              }))
              .fontSize(12)
              .fontColor([Color.White])
              .alignSelf(ItemAlign.Start)
              .fontWeight(FontWeight.Bold)
            Text(` ${SongConvertUtils.changeDuration(this.sliderMovingTime)}`)
              .transition(TransitionEffect.OPACITY.animation({
                duration: 300
              }))
              .fontSize(12)
              .textAlign(TextAlign.Start)
              .fontColor(Color.White)
              .alignSelf(ItemAlign.Start)
              .fontWeight(FontWeight.Bold)
          }
        }
          .layoutWeight(1)

        // 总时间
        Text(`${SongConvertUtils.changeDuration(nps.currentSong.duration)}`)
          .fontSize(12)
          .textAlign(TextAlign.End)
          .fontColor(Color.White)
          .alignSelf(ItemAlign.End)
          .layoutWeight(1)
      }
      .padding({ left: 5, right: 5 })
      .width('100%')
    }
    .width(wid)
    .height(this.shouldShowSlider || this.isMovingSlider ? undefined : 0)
    .opacity(this.shouldShowSlider || this.isMovingSlider ? 0.7 : 0)
    .animation({curve: curves.springMotion(0.6, 0.8)})
    .onClick(() => {
      this.showProgressBar()
    })
  }

  @Builder PlaybackControl() {
    Row() {
      // 上一首
      LightUpRoundedButton({
        icon: $r('sys.symbol.backward_end_fill'),
        customFontSize: 32,
        customFontColor: [Color.White],
        clickAction: () => {
          this.isBottomAreaExpand = false
          ClickUtil.throttle(() => {
            PlayControl.playPre()
          }, 500)
        },
        lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_LG])
      })

      // 播放
      LightUpBorderRoundButton({
        icon: nps.isPaused ? $r('sys.symbol.play_fill') : $r('sys.symbol.pause_fill'),
        customFontSize: 32,
        customPadding: nps.isPaused ? 10 : 14,
        customFontColor: [Color.White],
        customBgColor: Color.Transparent,
        clickAction: () => {
          this.isBottomAreaExpand = false
          if(nps.isPaused) {
            PlayControl.resumeMusic()
          } else {
            PlayControl.pauseMusic()
          }
        },
        lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_LG])
      })
        .shadow({
          color: '#ccffffff',
          radius: 36
        })
        .backgroundColor(nps.isPaused ? undefined : '#66ffffff')
        .backdropBlur(nps.isPaused ? undefined : 64)
        .animation({duration: 1000, curve: Curve.Ease})
        .borderRadius(48)

      // 下一首
      LightUpRoundedButton({
        icon: $r('sys.symbol.forward_end_fill'),
        customFontSize: 32,
        customFontColor: [Color.White],
        clickAction: () => {
          this.isBottomAreaExpand = false
          ClickUtil.throttle(() => {
            PlayControl.playNext()
          }, 500)
        },
        lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_LG])
      })
    }.justifyContent(FlexAlign.SpaceEvenly)
    .width('100%')
    .margin({bottom: ResponsiveUtil.widthCheck(['md']) ? 36 : 12})
    .animation({duration: 300, curve: Curve.Ease})
  }

  // -----------------------------------------------

  @Builder NowPlayingArea() {
    Column() {
      this.TopArea()
      this.CoverInfo()
      this.PlaybackControl()
    }.height('100%').width('100%')
    .padding({left: 24, right: 24})
    .justifyContent(FlexAlign.SpaceAround)
    .clip(false)
    .margin({bottom: this.gs.wd.bottom === 0 ? 24 : this.gs.wd.bottom})
  }

  @Builder LyricArea() {
    LyricComponent()
  }

  build() {
    Row() {
      Column() {
        Swiper() {
          this.NowPlayingArea()
          this.LyricArea()
        }.vertical(false)
        .displayCount(ResponsiveUtil.widthCheck(['md','lg','xl']) ? 2 : 1)
        .indicator(false)
        .animation({
          curve: curves.springMotion()
        })
        .width('100%').height('100%')
      }
      .width('100%')
    }
    .padding({
      top: this.gs.wd.top,
      // bottom: this.gs.wd.bottom
    })
    .height('100%')
    .visualEffect(new hdsEffect.HdsEffectBuilder()
      .shaderEffect({
        effectType: hdsEffect.EffectType.UV_BACKGROUND_FLOW_LIGHT,
        // params: {
        //   // firstEdgeFlowLight: {
        //   //   startPos: 0,
        //   //   endPos: 1.0,
        //   //   color: '#1AD0F1',
        //   // },
        //   // secondEdgeFlowLight: {
        //   //   startPos: 0.5,
        //   //   endPos: 1.5,
        //   //   color: '#FFA4E5',
        //   // },
        //   colorSource: this.backgroundFlowingColors,
        //   colorTarget: this.backgroundFlowingColors
        // },
        animation: {
          duration: 5000,
          iterations: -1,
          autoPlay: true,
          onFinish: ()=> {
            console.info('Succeeded in finishing');
          }
        },
        controller: this.controller,
      })
      // .pointLight({
      //   illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
      // })
      .buildEffect())
    // .backgroundColor(Color.Pink)

  }

  private handleSliderChange = (value: number, mode: SliderChangeMode) => {
    this.getUIContext().animateTo({ duration: 500, curve: Curve.Smooth, }, () => {
      if (mode == SliderChangeMode.Begin) {
        this.isMovingSlider = true
        this.sliderMovingTime = value
        this.sliderThickness = 15
      } else if (mode == SliderChangeMode.Moving) {
        this.sliderMovingTime = value
      } else if (mode == SliderChangeMode.End) {
        nps.playTime = value
        this.sliderThickness = 10
        this.isMovingSlider = false
        PlayControl.seekMusic(this.sliderMovingTime)
      }
    })
    if (mode == SliderChangeMode.End) {
      this.showProgressBar()
    }
  }
  async handleLike() {

  }

  @Monitor('_nps.currentSong')
  showProgressBar() {
    const showProgressBarTime = 5000

    if (this.shouldShowSliderTimeoutHandler) {
      clearTimeout(this.shouldShowSliderTimeoutHandler)
      this.shouldShowSliderTimeoutHandler = undefined
    }
    const context = this.getUIContext()
    const curve = ResponsiveUtil.chooseByWidth(
      [curves.springMotion(0.6, 0.8)])
    if (!this.shouldShowSlider) {
      context.animateTo({
        curve: curve
      }, () => {
        this.shouldShowSlider = true
      })
      this.shouldShowSliderTimeoutHandler = setTimeout(() => {
        this.getUIContext().animateTo({
          curve: curve
        }, () => {
          this.shouldShowSlider = false
        })
      }, showProgressBarTime)
    } else {
      this.shouldShowSliderTimeoutHandler = setTimeout(() => {
        this.getUIContext().animateTo({
          curve: curve
        }, () => {
          this.shouldShowSlider = false
        })
      }, showProgressBarTime)
    }
  }
}
