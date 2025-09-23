import { Song_INITIAL, PLAYMODE } from "@handwer/api_adapter"
import {
  NowPlayingStore,
  PlayQueueStore,
  GlobalStore,
  ResponsiveUtil,
  PlayControl,
  SongLike,
  PlayQueueUtils,
  ImgCache,
  ShareUtils,
  FeaturedPlayUtils,
  SongConvertUtils
} from "@handwer/base"
import {
  UIComponentUtils,
  DialogUtils,
  SnackBarUtils,
  LightUpRoundedButton,
  OverrideLightUpStat,
  LightUpBorderRoundButton,
  LightUpConfig
} from "@handwer/ui_components"
import { ClickUtil } from "@pura/harmony-utils"
import { EmptyStateView } from "../components"
import { systemShare } from "@kit.ShareKit"
import { HdsSnackBar, HdsActionBar, ActionBarButton } from "@kit.UIDesignKit"
import { uniformTypeDescriptor } from "@kit.ArkData"
import { curves, LengthMetrics, SymbolGlyphModifier, ColorMetrics } from "@kit.ArkUI"
import { ImageCover } from "../components/ImageCover"

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
export struct PlayerUIArea {
  // 从 MainPage 传入的必要属性
  @Param @Require hdsSnackBar: HdsSnackBar
  @Param @Require showExplore: boolean
  @Param @Require onExploreClick: () => void
  @Param @Require onQueueSheetToggle: () => void
  @Param @Require onAddToPlaylistSheet: () => void
  @Param @Require onConsoleSheetToggle: () => void
  @Param @Require bottomPlayControlShouldLift: Length

  // PlayerUIArea 内部状态变量
  @Local isTopAreaExpand: boolean = false
  @Local isBottomAreaExpand: boolean = false
  @Local sliderThickness: number = 10
  @Local isMovingSlider: boolean = false
  @Local sliderMovingTime: number = 0
  @Local shouldShowSlider: boolean = false
  shouldShowSliderTimeoutHandler?: number

  // 引用外部store
  nps = NowPlayingStore
  pq = PlayQueueStore
  gs = GlobalStore

  // Getter方法
  get topAreaExpandShouldHideNormal() {
    return this.isTopAreaExpand && ResponsiveUtil.widthCheck(['xs','sm', 'md'])
  }
  get todayIcon() {
    return UIComponentUtils.getTodayIcon()
  }
  get isThisSongLiked() {
    return this.nps.isLiked
  }
  get shouldShowEmptyState() {
    return this.nps.currentSong === Song_INITIAL || (this.nps.currentSong.id === "" && this.pq.queue.length === 0)
  }
  get nowPlayingCoverImg(): string {
    if (this.nps.currentSong === Song_INITIAL) {
      return ''
    } else {
      return this.nps.playMode === PLAYMODE.LOCAL ? this.nps.currentPic as string : (this.nps.currentPic as string) + '?param=512y512'
    }
  }

  // 业务逻辑函数
  private handleSliderChange = (value: number, mode: SliderChangeMode) => {
    this.getUIContext().animateTo({ duration: 500, curve: Curve.Smooth, }, () => {
      if (mode == SliderChangeMode.Begin) {
        this.isMovingSlider = true
        this.sliderMovingTime = value
        this.sliderThickness = 15
      } else if (mode == SliderChangeMode.Moving) {
        this.sliderMovingTime = value
      } else if (mode == SliderChangeMode.End) {
        this.nps.playTime = value
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
    DialogUtils.showHeartDialog1sec(!NowPlayingStore.isLiked)
    SongLike.likeThisSong((icon, msg) => {
      SnackBarUtils.showMessage(this.hdsSnackBar, icon, msg)
    })
  }

  @Monitor('nps.currentSong')
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

  // @Builder 方法
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
            baseIcon: this.nps.isLiked ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'),
            baseIconSymbolGlyphModifier: this.nps.isLiked ? new SymbolGlyphModifier().fontColor([Color.Red]) : undefined,
            width: LengthMetrics.vp(40),
            enabled: !NowPlayingStore.isPlayingOuter,
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
              this.onAddToPlaylistSheet()
            }
          }),
          new ActionBarButton({
            baseIcon: $r('sys.symbol.share'),
            width: LengthMetrics.vp(40),
            onClick: async () => {
              const ctx = this.getUIContext().getHostContext()!
              const img = await DialogUtils.showLoadingUntil((): Promise<string> => {
                return ImgCache.download(NowPlayingStore.currentPic as string);
              });
              const thumb = await ShareUtils.copyUriAsThumbnail(ctx, img)
              ShareUtils.startKnockShare(ctx.getApplicationContext()!,
                (onClose): string => {
                  return DialogUtils.showKnockShareDialog(onClose);
                }, (target) => {
                  let shareData: systemShare.SharedData = new systemShare.SharedData({
                    utd: uniformTypeDescriptor.UniformDataType.HYPERLINK,
                    content: PlayControl.generateShareLink(),
                    title: NowPlayingStore.currentSong.name,
                    thumbnailUri: thumb
                  });
                  target.share(shareData)
                })
            }
          }),
        ]
      })
        .hitTestBehavior(this.isBottomAreaExpand ? HitTestMode.Default : HitTestMode.Transparent)
        .offset(this.isBottomAreaExpand ? {x: 0, y: 0} : {x: 5, y: 0})
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
            backgroundColor: this.nps.isHeartMode ? ColorMetrics.numeric(0xFFFFFFFF) : undefined,
            baseIconSymbolGlyphModifier: this.nps.isHeartMode ? new SymbolGlyphModifier().fontColor([Color.Black]) : undefined,
            onClick: () => {
              FeaturedPlayUtils.playHeartMode((icon, msg) => {
                SnackBarUtils.showMessage(this.hdsSnackBar, icon, msg)
              })
            }
          }),
          new ActionBarButton({
            baseIcon: this.todayIcon,
            width: LengthMetrics.vp(40),
            backgroundColor: this.nps.isDailyListMode ? ColorMetrics.numeric(0xFFFFFFFF) : undefined,
            baseIconSymbolGlyphModifier: this.nps.isDailyListMode ? new SymbolGlyphModifier().fontColor([Color.Black]) : undefined,
            onClick: () => {
              FeaturedPlayUtils.playDailySongs((icon, msg) => {
                SnackBarUtils.showMessage(this.hdsSnackBar, icon, msg)
              }, this.todayIcon)
            }
          }),
          new ActionBarButton({
            baseIcon: $r('sys.symbol.radiostation'),
            width: LengthMetrics.vp(40),
            baseIconSymbolGlyphModifier: this.nps.isPersonalFM ? new SymbolGlyphModifier().fontColor([Color.Black]) : undefined,
            backgroundColor: this.nps.isPersonalFM ? ColorMetrics.numeric(0xFFFFFFFF) : undefined,
            onClick: () => {
              FeaturedPlayUtils.playPersonalizedFM((icon, msg) => {
                SnackBarUtils.showMessage(this.hdsSnackBar, icon, msg)
              })
            }
          }),
          new ActionBarButton({
            baseIcon: $r('sys.symbol.gearshape'),
            width: LengthMetrics.vp(40),
            onClick: () => {
              this.isTopAreaExpand = false
              this.isBottomAreaExpand = false
              this.onConsoleSheetToggle()
            }
          }),
        ]
      })
        .hitTestBehavior(this.isTopAreaExpand ? HitTestMode.Default : HitTestMode.Transparent)
        .offset(!this.topAreaExpandShouldHideNormal ? {x: -5, y: 0} : {x: 0, y: 0})
    }.hitTestBehavior(this.isTopAreaExpand ? HitTestMode.Default : HitTestMode.Transparent)
  }

  @Builder TopAreaActionButton_Normal() {
    Row({space: 24}) {
      Blank().width(40)

      Text('来自外部的歌曲')
        .fontColor(Color.White)
        .visibility(NowPlayingStore.isPlayingOuter ? Visibility.Visible : Visibility.None)

      LightUpRoundedButton({
        lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_TOP_BTN_SM, LIGHT_TOP_BTN_MD, LIGHT_TOP_BTN_LG]),
        icon: $r('sys.symbol.house'),
        customBgColor: $r('sys.color.icon_fourth'),
        clickAction: () => {
          this.onExploreClick()
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
      Text(this.nps.currentSong.name)
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
      Text(this.nps.currentArtists)
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
    .padding({right: 44})
    .transition(TransitionEffect.OPACITY.animation({duration: 200}))
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      this.onQueueSheetToggle()
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
        })
      }.layoutWeight(1)

      Stack(){
        this.AuthorInfo()
        this.BottomAreaControlButton_ActionBar()
      }
      .alignContent(this.isBottomAreaExpand ? Alignment.Center : Alignment.End)
      .animation({curve: curves.springMotion()})

      this.ProgressBar('90%')
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
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
      Slider({
        value: this.nps.playTime,
        min: 0,
        max: this.nps.currentSong.duration,
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
        Row(){
          Text(`${SongConvertUtils.changeDuration(this.nps.playTime)}`)
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

        Text(`${SongConvertUtils.changeDuration(this.nps.currentSong.duration)}`)
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
    .height(this.shouldShowSlider || this.isMovingSlider ? 'auto' : 0)
    .opacity(this.shouldShowSlider || this.isMovingSlider ? 0.7 : 0)
    .animation({curve: curves.springMotion(0.6, 0.8)})
    .onClick(() => {
      this.showProgressBar()
    })
  }

  @Builder PlaybackControl() {
    Row() {
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

      LightUpBorderRoundButton({
        icon: this.nps.isPaused ? $r('sys.symbol.play_fill') : $r('sys.symbol.pause_fill'),
        customFontSize: 32,
        customPadding: this.nps.isPaused ? 10 : 14,
        customFontColor: [Color.White],
        customBgColor: Color.Transparent,
        clickAction: () => {
          this.isBottomAreaExpand = false
          if(this.nps.isPaused) {
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
        .backgroundColor(this.nps.isPaused ? undefined : '#66ffffff')
        .backdropBlur(this.nps.isPaused ? undefined : 64)
        .animation({duration: 1000, curve: Curve.Ease})
        .borderRadius(48)

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

  build() {
    if (this.shouldShowEmptyState) {
      // 空状态视图
      EmptyStateView({
        hdsSnackBar: this.hdsSnackBar,
        onExploreClick: this.onExploreClick
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
      .padding({left: 24, right: 24, bottom: this.bottomPlayControlShouldLift})
      .justifyContent(FlexAlign.SpaceAround)
      .clip(false)
      .margin({bottom: this.gs.wd.bottom === 0 ? 24 : this.gs.wd.bottom})
    }
  }
}
