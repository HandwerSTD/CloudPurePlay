import { FeaturedPlayUtils,
  GlobalContext,
  GlobalStore, Logger, NowPlayingStore, PlayControl,
  PlayQueueStore,
  PlayQueueUtils,
  ResponsiveUtil,
  SCApp,
  SCGlobal,
  SCPref,
  Settings,
  SongConvertUtils,
  SongLike,
  ThemeManager,
  UserStore } from "@handwer/base"
import { PLAYMODE, Song_INITIAL } from "@handwer/api_adapter"
import { LightUpRoundedButton, LightUpConfig, LightUpDefaultConfig, OverrideLightUpStat, LightUpBorderRoundButton, SnackBarUtils,
  UIComponentUtils,
  LightUpContainer,
  AddToPlaylistSheet} from "@handwer/ui_components"
import { ColorMetrics, curves, LengthMetrics, SymbolGlyphModifier } from "@kit.ArkUI"
import { ClickUtil } from "@pura/harmony-utils"
import { HdsActionBar, ActionBarButton, hdsEffect, HdsSnackBar } from "@kit.UIDesignKit"
import { LyricComponent } from "./LyricArea"
import { ImageCover, ImageCoverThumbnail } from "../components/ImageCover"
import { PlayQueueViewBuilder } from "./PlayQueueView"
import { ExplorePageBuilder } from "@handwer/explore"
import { EmptyStateView, EmptyStateViewBar } from "../components/EmptyStateView"

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

  @Consumer(SCApp.settingsSheet) consoleSheet: boolean = false
  @Provider(SCApp.playQueueSheet) showQueueSheet: boolean = false
  @Provider(SCApp.exploreSheet) showExplore: boolean = false
  @Provider(SCApp.showAddToPlaylistSheet) showAddToPlaylistSheet: boolean = false

  controller: hdsEffect.ShaderEffectController = new hdsEffect.ShaderEffectController()

  get swiperHeight(): Length | undefined {
    if (!this.showExplore) return '100%'
    return 100
  }
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
  get shouldShowEmptyState() {
    return nps.currentSong === Song_INITIAL || (nps.currentSong.id === "" && this.pq.queue.length === 0)
  }
  get isQueueEmpty() {
    return this.pq.queue.length === 0
  }
  
  pq = PlayQueueStore
  @Local sliderThickness: number = 10
  @Local isMovingSlider: boolean = false
  @Local sliderMovingTime: number = 0
  @Local shouldShowSlider: boolean = false
  shouldShowSliderTimeoutHandler?: number

  @Local backgroundFlowingColors: ResourceColor[] = [Color.Black, Color.Blue, Color.Pink]

  @Local isTopAreaExpand: boolean = false

  @Local isBottomAreaExpand: boolean = false

  @Local explorePageOpacity: number = 0


  // ----------------------------------------

  @Builder addToPlaylistSheet() {
    AddToPlaylistSheet()
  }

  @Builder BottomAreaControlButton_ActionBar_PrimaryButton() {
    Stack({alignContent: Alignment.BottomEnd}){
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
      LightUpRoundedButton({
        icon: $r('sys.symbol.heart_fill'),
        customFontColor: [Color.Red],
        customFontSize: 12,
        customPadding: 4,
        overrideLightUpStat: OverrideLightUpStat.ALWAYS_ENABLED,
        clickAction: () => {
          this.isBottomAreaExpand = !this.isBottomAreaExpand
        },
        lightUpConfig: {
          lightIntensity: 1,
          lightHeight: 60
        }
      })
        .visibility(this.isThisSongLiked && !this.isBottomAreaExpand ? Visibility.Visible : Visibility.None)
        // .transition(TransitionEffect.OPACITY.animation({duration: 200}))
        .translate({x: 6, y: 6})
    }
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
            baseIcon: $r('sys.symbol.add_songlist'),
            width: LengthMetrics.vp(40),
            onClick: () => {
              this.showAddToPlaylist()
            }
          }),
        ]
      })
        .hitTestBehavior(this.isBottomAreaExpand ? HitTestMode.Default : HitTestMode.Transparent)
        .offset(this.isBottomAreaExpand ? undefined : {x: 5}) // 抵消掉自带边距
    }.hitTestBehavior(this.isBottomAreaExpand ? HitTestMode.Default : HitTestMode.Transparent)
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
            baseIcon: $r('sys.symbol.radiostation'),
            width: LengthMetrics.vp(40),
            baseIconSymbolGlyphModifier: nps.isPersonalFM ? new SymbolGlyphModifier().fontColor([Color.Black]) : undefined,
            backgroundColor: nps.isPersonalFM ? ColorMetrics.numeric(0xFFFFFFFF) : undefined,
            onClick: () => {
              FeaturedPlayUtils.playPersonalizedFM((icon, msg) => {
                SnackBarUtils.showMessage(this.hdsSnackBar, icon, msg)
              })
            }
          }),
          new ActionBarButton({
            baseIcon: $r('sys.symbol.speaker_wave_3'),
            width: LengthMetrics.vp(40),
            onClick: () => {

            }
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
        icon: $r('sys.symbol.house'),
        customBgColor: $r('sys.color.icon_fourth'),
        clickAction: () => {
          this.showExplore = true
          this.isTopAreaExpand = false
          this.isBottomAreaExpand = false
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
            // this.backgroundFlowingColors = colors
            // Logger.debug(`try resetting flow colors: `, this.backgroundFlowingColors.toString())
            // this.controller.setEffectParams({
            //   colorSource: this.backgroundFlowingColors
            // },)
            // this.controller.play()
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
    if (this.shouldShowEmptyState) {
      // 空状态视图
      EmptyStateView({
        hdsSnackBar: this.hdsSnackBar,
        onExploreClick: () => {
          this.showExplore = true
          this.isTopAreaExpand = false
          this.isBottomAreaExpand = false
        }
      })
      .height('100%')
      .width('100%')
      .padding({left: 24, right: 24})
        .transition(TransitionEffect.OPACITY.animation({duration: 500}))
    } else {
      // 正常播放状态视图
      Column() {
        this.TopArea()
        this.CoverInfo()
        this.PlaybackControl()
      }.height('100%').width('100%')
      .padding({left: 24, right: 24})
      .justifyContent(FlexAlign.SpaceAround)
      .clip(false)
      .margin({bottom: this.gs.wd.bottom === 0 ? 24 : this.gs.wd.bottom})
      // .transition(TransitionEffect.OPACITY.animation({duration: 300}))
    }
  }

  @Builder LyricArea() {
    if (!this.shouldShowEmptyState) {
      LyricComponent({
        miniMode: this.showExplore
      })
        .translate(this.showExplore ? {y: -10} : undefined)
    }
  }

  // -----------------------------------------------

  @Builder NowPlayingArea_Bar() {
    if (this.shouldShowEmptyState) {
      // 空状态时显示简化的导航栏
      Row() {

        EmptyStateViewBar()
          .onClick(() => {
            this.showExplore = false
          })
      }.width('100%')
    } else {
      // 正常状态的播放栏
      Row() {
        ImageCoverThumbnail({
          nowPlayingCoverImg: this.nowPlayingCoverImg
        })
          .onClick(() => {
            this.showExplore = false
          })
        this.AuthorInfo_Bar()
        this.PlaybackButton_Bar()
      }.width('100%')
      .padding({left: ResponsiveUtil.chooseByWidth([12, 12, 24]),
        right: 24,
        top: 8, bottom: 8})
    }
  }
  @Builder AuthorInfo_Bar() {
    Column() {
      Text(nps.currentSong.name)
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
        .textAlign(TextAlign.Start)
        .textOverflow({
          overflow: TextOverflow.MARQUEE
        })
        .marqueeOptions({
          start: true,
          fadeout: true
        })
        .fontColor(Color.White)
    }.layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      this.showQueueSheet = !this.showQueueSheet
    })
  }
  @Builder PlaybackButton_Bar() {
    Row({space: 12}) {
      // 上一首
      LightUpRoundedButton({
        icon: $r('sys.symbol.backward_end_fill'),
        customFontSize: 20,
        customFontColor: [Color.White],
        clickAction: () => {
          this.isBottomAreaExpand = false
          ClickUtil.throttle(() => {
            PlayControl.playPre()
          }, 500)
        },
        lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_LG])
      })
        .visibility(ResponsiveUtil.chooseByWidth([Visibility.None, Visibility.None, Visibility.Visible]))

      // 播放
      LightUpBorderRoundButton({
        icon: nps.isPaused ? $r('sys.symbol.play_fill') : $r('sys.symbol.pause_fill'),
        customFontSize: 20,
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
        customFontSize: 20,
        customFontColor: [Color.White],
        clickAction: () => {
          this.isBottomAreaExpand = false
          ClickUtil.throttle(() => {
            PlayControl.playNext()
          }, 500)
        },
        lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_LG])
      })
    }
    .margin({ left: 24})
    .animation({duration: 300, curve: Curve.Ease})
  }

  @Builder LightUpProgress() {
    Row() {
      LightUpProgressBar()
    }.width('100%').padding({left: 12+25, right: 12+25})
  }

  // ------------------------

  @Builder ExplorePageShell() {
    Column() {
      Column() {
        ExplorePageBuilder()
      }.clip(true)
      .borderRadius(24)
      .shadow(ShadowStyle.OUTER_FLOATING_SM)
      .backgroundColor($r('sys.color.comp_background_secondary'))
      .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
        illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
      }).buildEffect())
      // .backdropBlur(64) // 背景本身就是模糊的了，多加一层没意义
      .width('100%').height('100%')
    }.width('100%').padding({left: 12, right: 12})
    .layoutWeight(1)
    .opacity(this.explorePageOpacity)
    .animation({duration: 300})
  }

  aboutToAppear(): void {
    const showPlayer = Settings.get<boolean>(SCPref.showPlayerOnLaunch) ?? true
    if (showPlayer) {
      this.showExplore = false
      this.explorePageOpacity = 0
    } else {
      this.showExplore = true
      this.explorePageOpacity = 1
    }
  }

  @Builder BackgroundFlow() {

    Column() {
      if (GlobalStore.isDarkMode) {
        Column().width('100%').height('100%')
          .visualEffect(new hdsEffect.HdsEffectBuilder()
            .shaderEffect({
              effectType: hdsEffect.EffectType.UV_BACKGROUND_FLOW_LIGHT,
              params: {
                colorSource: [Color.Black, Color.Blue, Color.Pink],
              },
              // animation: {
              //   duration: 5000,
              //   autoPlay: true,
              //   iterations: -1
              // }
            })
            .buildEffect())
          .transition(TransitionEffect.OPACITY.animation({duration: 2000}))
      } else {
        Column().width('100%').height('100%')
          .visualEffect(new hdsEffect.HdsEffectBuilder()
            .shaderEffect({
              effectType: hdsEffect.EffectType.UV_BACKGROUND_FLOW_LIGHT,
              // controller: this.controller,
              // animation: {
              //   duration: 5000,
              //   autoPlay: true,
              //   iterations: -1
              // }
            })
            .buildEffect())
          .transition(TransitionEffect.OPACITY.animation({duration: 2000}))
      }
    }.width('100%').height('100%')
  }

  build() {
    Stack() {
      this.BackgroundFlow()
      Row() {
        Column() {
          this.ExplorePageShell()
          if (this.showExplore) {
            this.LightUpProgress()
          }
          Swiper() {
            if (!this.showExplore) {
              // Normal
              this.NowPlayingArea()
            } else {
              // Bottom Bar
              this.NowPlayingArea_Bar()
            }
            this.LyricArea()
          }.vertical(false)
          .displayCount(ResponsiveUtil.widthCheck(['md','lg','xl']) && !this.shouldShowEmptyState ? 2 : 1)
          .indicator(false)
          .animation({
            curve: curves.springMotion()
          })
          .width('100%').height(this.swiperHeight)
          .animation({curve: curves.springMotion(0.6, 0.8)})
        }.justifyContent(FlexAlign.End)
        .width('100%')
        .height('100%')
        .bindSheet(this.showQueueSheet!!, PlayQueueViewBuilder, {
          showClose: false,
          scrollSizeMode: ScrollSizeMode.CONTINUOUS,
          preferType: SheetType.SIDE,
          blurStyle: BlurStyle.BACKGROUND_REGULAR,
          backgroundColor: $r('app.color.ui_sheet_bg_col')
        })
      }
      .bindSheet(this.showAddToPlaylistSheet!!, this.addToPlaylistSheet(), {
        showClose: false,
        backgroundColor: $r('app.color.ui_sheet_bg_col'),
        blurStyle: BlurStyle.BACKGROUND_THICK,
        preferType: SheetType.CENTER
      })
      .padding({
        top: this.gs.wd.top === 0 ? 12 : this.gs.wd.top,
        // bottom: this.gs.wd.bottom
      })
      .height('100%')
    }
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
        if (this.sliderMovingTime !== -1) {
          PlayControl.seekMusic(this.sliderMovingTime)
        }
        this.sliderMovingTime = -1
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

  @Monitor('showExplore')
  onExplorePage() {
    if (this.showExplore) {
      this.explorePageOpacity = 1
      // this.controller.pause()
    } else {
      this.explorePageOpacity = 0
      // this.controller.play()
    }
  }

  showAddToPlaylist() {
    GlobalContext.getContext().setObject(SCGlobal.addToPlaylistSongData, nps.currentSong)
    this.showAddToPlaylistSheet = true
  }
}

@ComponentV2
struct LightUpProgressBar {

  @Local totalWidth: number = 0

  nps = NowPlayingStore

  get blankLeftWidth() {
    if (this.nps.currentSong.duration === 0) return 0
    return (this.nps.playTime / this.nps.currentSong.duration) * this.totalWidth
  }

  get shouldShow() {
    return this.nps.currentSong !== Song_INITIAL && this.nps.currentSong.id !== ""
  }

  @Local intensity: number = 0

  aboutToAppear(): void {
    setTimeout(() => {
      this.onLightUpdate()
    }, 1000)
  }
  @Monitor('nps.isPaused')
  onLightUpdate() {
    if (this.nps.isPaused || !this.shouldShow) {
      this.intensity = 0
    } else {
      this.intensity = 2
    }
  }

  build() {
    if (this.shouldShow) {
      Stack() {
        // Row().width('100%').height(1).backgroundColor('#88ffffff')
        Row() {
          Blank().width(this.blankLeftWidth).animation({duration: 100})

          Column() {}.width(5).height(5).translate({y: -2.5})
          .backgroundColor(Color.White)
          .borderRadius(10)
          .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
            options: {
              intensity: this.intensity,
              height: 90
            }
          }).buildEffect())
          .opacity(this.intensity === 0 ? 0.5 : 1)
          .animation({duration: 300})
        }.width('100%').justifyContent(FlexAlign.Start)
        .onAreaChange((_, nw) => {
          this.totalWidth = nw.width.valueOf() as number
        })
      }
    } else {
      // 空状态时显示占位符或不显示任何内容
      Stack() {}.height(0)
    }
  }
}
