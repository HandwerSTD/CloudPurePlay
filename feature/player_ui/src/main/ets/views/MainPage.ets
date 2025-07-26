import { FeaturedPlayUtils, GlobalStore, NowPlayingStore, PlayControl, ResponsiveUtil } from "@handwer/base"
import { PLAYMODE, SongConvertUtils, Song_INITIAL } from "@handwer/cloud_api"
import { LightUpRoundedButton, LightUpConfig, LightUpBorderRoundButton, SnackBarUtils } from "@handwer/ui_components"
import { ColorMetrics, curves, LengthMetrics } from "@kit.ArkUI"
import { ClickUtil } from "@pura/harmony-utils"
import { HdsActionBar, ActionBarButton, ActionBarStyle, hdsEffect, HdsSnackBar } from "@kit.UIDesignKit"
import { cacheDownload } from "@kit.BasicServicesKit"
import { LyricComponent } from "./LyricArea"

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

  @Consumer('consoleSheet') consoleSheet: boolean = false

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
  @Local sliderThickness: number = 10
  @Local isMovingSlider: boolean = false
  @Local sliderMovingTime: number = 0

  @Local isTopAreaExpand: boolean = false
  @Builder TopAreaActionButton_ActionBar_PrimaryButton() {
    LightUpRoundedButton({
      lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_TOP_BTN_SM, LIGHT_TOP_BTN_MD, LIGHT_TOP_BTN_LG]),
      icon: $r('sys.symbol.star_planet'),
      customBgColor: $r('sys.color.icon_fourth'),
      clickAction: () => {
        this.isTopAreaExpand = !this.isTopAreaExpand
      },
      customFontColor: this.isTopAreaExpand ? [$r('sys.color.font_secondary')] : [Color.White, Color.White]
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
            onClick: () => {
              FeaturedPlayUtils.playHeartMode((icon, msg) => {
                SnackBarUtils.showMessage(this.hdsSnackBar, icon, msg)
              })
            }
          }),
          new ActionBarButton({
            baseIcon: $r('sys.symbol.radio'),
            width: LengthMetrics.vp(40),
            onClick: () => {
              FeaturedPlayUtils.playPersonalizedFM()
            }
          }),
          new ActionBarButton({
            baseIcon: $r('sys.symbol.house'),
            width: LengthMetrics.vp(40)
          }),
          new ActionBarButton({
            baseIcon: $r('sys.symbol.speaker_wave_3'),
            width: LengthMetrics.vp(40)
          })
        ]
      })
        .hitTestBehavior(this.isTopAreaExpand ? HitTestMode.Default : HitTestMode.Transparent)
    }.hitTestBehavior(this.isTopAreaExpand ? HitTestMode.Default : HitTestMode.Transparent)
  }
  @Builder TopAreaActionButton_Normal() {
    Row({space: 24}) {
      // Discover
      Blank()

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
    .padding(this.topAreaExpandShouldHideNormal ? {} : {left: 24, right: 24, top: 24})
    .alignContent(this.topAreaExpandShouldHideNormal ? Alignment.Center : Alignment.Start)
    .animation({curve: curves.springMotion()})
  }

  @Builder CoverInfo() {
    Column() {
      // TODO: 考虑在播放时封面背后放一个点光源？
      Row() {
        ImageCover({
          nowPlayingCoverImg: this.nowPlayingCoverImg,
          handleLike: () => {
            this.handleLike()
          },
          useLight: true,
          useCoverAmbBreathe: false
        })
      }.layoutWeight(1)
      Blank().height(24)
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
      Blank().height(24)

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
    .opacity(0.6)
  }

  @Builder PlaybackControl() {
    Row() {
      // 上一首
      LightUpRoundedButton({
        icon: $r('sys.symbol.backward_end_fill'),
        customFontSize: 32,
        customFontColor: [Color.White],
        clickAction: () => {
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
          ClickUtil.throttle(() => {
            PlayControl.playNext()
          }, 500)
        },
        lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_LG])
      })
    }.justifyContent(FlexAlign.SpaceEvenly)
    .width('100%')
    .margin({bottom: ResponsiveUtil.widthCheck(['md']) ? 24 : 0})
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
      //   illuminatedType: hdsEffect.PointLightIlluminatedType.CONTENT
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
}
  async handleLike() {

  }
}


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
            this.handleLike()
          })
        )
    }.alignContent(Alignment.TopStart)
  }
}

@ComponentV2
export struct LyricArea {
  build() {

  }
}