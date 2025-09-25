import { FeaturedPlayUtils,
  GlobalContext,
  GlobalStore,
  ImgCache,
  Logger, NowPlayingStore, PlayControl,
  PlayQueueStore,
  PlayQueueUtils,
  ResponsiveUtil,
  SCApp,
  SCGlobal,
  SCPref,
  Settings,
  ShareUtils,
  SongConvertUtils,
  SongLike,
  ThemeManager,
  UserStore } from "@handwer/base"
import { APIConfigUtils, InstanceSwitcher, PLAYMODE, Song_INITIAL } from "@handwer/api_adapter"
import { LightUpRoundedButton, LightUpConfig, LightUpDefaultConfig, OverrideLightUpStat, LightUpBorderRoundButton, SnackBarUtils,
  UIComponentUtils,
  LightUpContainer,
  AddToPlaylistSheet,
  DialogUtils,
  LightUpLongButton,
  LightUpIconTextButton,
  BgFlowController} from "@handwer/ui_components"
import { ColorMetrics, curves, LengthMetrics, SymbolGlyphModifier } from "@kit.ArkUI"
import { ClickUtil } from "@pura/harmony-utils"
import { HdsActionBar, ActionBarButton, hdsEffect, HdsSnackBar } from "@kit.UIDesignKit"
import { LyricComponent } from "./LyricArea"
import { ImageCover, ImageCoverThumbnail } from "../components/ImageCover"
import { PlayQueueViewBuilder } from "./PlayQueueView"
import { ExplorePageBuilder } from "@handwer/explore"
import { EmptyStateView, EmptyStateViewBar } from "../components/EmptyStateView"
import { unifiedDataChannel, uniformTypeDescriptor } from "@kit.ArkData"
import { harmonyShare, systemShare } from "@kit.ShareKit"
import { ApplicationStateChangeCallback, common } from "@kit.AbilityKit"
import { BackgroundFlow } from "./BackgroundFlow"
import { PlayerUIArea } from "./PlayerArea"
import { LightUpProgressBar } from "../components/PlaybackControlComponent"

const nps = NowPlayingStore

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

const BAR_OFFSET = 6

const SLIDE_BAR_MAXH = 48

@ComponentV2
export struct MainPage {
  hdsSnackBar = new HdsSnackBar(this.getUIContext())
  gs = GlobalStore
  user = UserStore

  _nps = NowPlayingStore

  @Consumer(SCApp.settingsSheet) consoleSheet: boolean = false
  @Provider(SCApp.playQueueSheet) showQueueSheet: boolean = false
  @Consumer(SCApp.exploreSheet) showExplore: boolean = false
  @Provider(SCApp.showAddToPlaylistSheet) showAddToPlaylistSheet: boolean = false

  controller?: hdsEffect.ShaderEffectController

  get swiperHeight(): Length | undefined {
    if (!this.showExplore) return '100%'
    if (ResponsiveUtil.wLgXl()) return 100
    return 80 + BAR_OFFSET
  }
  get bottomPlayControlShouldLift(): Length {
    return 36 + 24
  }
  get nowPlayingCoverImg(): string {
    if (nps.currentSong === Song_INITIAL) {
      return ''
    } else {
      return nps.playMode === PLAYMODE.LOCAL ? nps.currentPic as string : (nps.currentPic as string) + '?param=512y512'
    }
  }
  get shouldShowEmptyState() {
    return nps.currentSong === Song_INITIAL || (nps.currentSong.id === "" && this.pq.queue.length === 0)
  }
  get isQueueEmpty() {
    return this.pq.queue.length === 0
  }
  
  pq = PlayQueueStore
  @Local backgroundFlowingColors: ResourceColor[] = [Color.Black, Color.Blue, Color.Pink]
  @Local explorePageOpacity: number = 0

  // 为Bar模式保留的属性
  get isThisSongLiked() {
    return nps.isLiked
  }

  // ----------------------------------------

  @Builder addToPlaylistSheet() {
    AddToPlaylistSheet()
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
  // TODO: Pura X 适配
  // TODO: 点击展开 / 滑动展开 等等其他交互
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
        this.AuthorInfo_Bar()
        this.PlaybackButton_Bar()
      }.width('100%')
      .padding({left: ResponsiveUtil.chooseByWidth([12, 12, 24]),
        right: 24,
        top: 8, bottom: 8 + BAR_OFFSET})
      .clip(false)
      .onClick(() => {
        this.showExplore = false
      })
      .gesture(PanGesture({direction: PanDirection.Vertical}).onActionStart((event) => {
        this.onPrepareSlideToPlay(event.offsetY)
      }).onActionUpdate((event) => {
        this.onSlideToPlay(event.offsetY)
      }).onActionEnd((event) => {
        this.onSlideToPlayFinish()
      }))
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
        .fontSize(20)
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
    // .onClick(() => {
    //   this.showQueueSheet = !this.showQueueSheet
    // })
  }
  @Builder PlaybackButton_Bar() {
    Row({space: 12}) {
      // 上一首
      LightUpRoundedButton({
        icon: $r('sys.symbol.backward_end_fill'),
        customFontSize: 20,
        customFontColor: [Color.White],
        clickAction: () => {
          ClickUtil.throttle(() => {
            PlayControl.playPre()
          }, 500)
        },
        lightUpConfig: ResponsiveUtil.chooseByWidth([LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_MD,LIGHT_PLAYBACK_BTN_LG])
      })
        .visibility(ResponsiveUtil.chooseByWidth([Visibility.None, Visibility.None, Visibility.Visible]))

      // 播放
      Stack({alignContent: Alignment.BottomEnd}){
        LightUpBorderRoundButton({
          icon: nps.isPaused ? $r('sys.symbol.play_fill') : $r('sys.symbol.pause_fill'),
          customFontSize: 20,
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
          .gesture((LongPressGesture({duration: 1000})).onAction(() => {
            DialogUtils.showHeartDialog1sec(!NowPlayingStore.isLiked)
            SongLike.likeThisSong((icon, msg) => {
              SnackBarUtils.showMessage(this.hdsSnackBar, icon, msg)
            })
          }))
        LightUpRoundedButton({
          icon: $r('sys.symbol.heart_fill'),
          customFontColor: [Color.Red],
          customFontSize: 8,
          customPadding: 3,
          overrideLightUpStat: OverrideLightUpStat.ALWAYS_ENABLED,
          clickAction: () => {},
          lightUpConfig: {
            lightIntensity: 1,
            lightHeight: 60
          }
        })
          .visibility(this.isThisSongLiked ? Visibility.Visible : Visibility.None)
          .translate({x: 4, y: 4})
          .hitTestBehavior(HitTestMode.Transparent)
      }

      // 下一首
      LightUpRoundedButton({
        icon: $r('sys.symbol.forward_end_fill'),
        customFontSize: 20,
        customFontColor: [Color.White],
        clickAction: () => {
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
    }.width('100%').padding(ResponsiveUtil.chooseByWidth<Padding>([
      {left: 8, right: 8}, {left: 12, right: 12}
    ]))
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
    this.onRightHandMode()
    this.registerGestureShare()
  }

  @Builder BackgroundFlow() {
    BackgroundFlow()
  }

  @Local swiperArr: number[] = [0, 1]
  @Builder SwiperItem(index: number) {
    if (index === 0) {
      if (!this.showExplore) {
        // Normal

        PlayerUIArea({
          hdsSnackBar: this.hdsSnackBar,
          showExplore: this.showExplore,
          onExploreClick: () => {
            this.showExplore = true
          },
          onQueueSheetToggle: () => {
            this.showQueueSheet = !this.showQueueSheet
          },
          onAddToPlaylistSheet: () => {
            this.showAddToPlaylist()
          },
          onConsoleSheetToggle: () => {
            this.consoleSheet = !this.consoleSheet
          },
          bottomPlayControlShouldLift: this.bottomPlayControlShouldLift
        })
          .gesture(PanGesture({direction: PanDirection.Vertical}).onActionStart((event) => {
            this.onPrepareSlideToPlay(event.offsetY)
          }).onActionUpdate((event) => {
            this.onSlideToPlay(event.offsetY)
          }).onActionEnd((event) => {
            this.onSlideToPlayFinish()
          }))
          .translate({
            y: this.slideGesOffset === 0 ? 0 : this.slideBlurPer * 12
          })
      } else {
        // Bottom Bar
        this.NowPlayingArea_Bar()
      }
    } else {
      this.LyricArea()
    }
  }
  @Provider('slideBlurPer') slideBlurPer: number = 0

  get SlideToPlayIndicatorHeight() {
    if (!GlobalStore.pref.swipeToNextTrack) return 0
    const offset = (this.slideGesOffset ?? 0) * 0.4
    if (offset >= 0) return 0
    return Math.abs(offset)
  }
  get SlideToHouseIndicatorHeight() {
    const offset = (this.slideGesOffset ?? 0) * 0.4
    if (offset <= 0) return 0
    return Math.abs(offset)
  }
  @Builder SlideToPlayIndicator() {
    Column() {
      if (this.showExplore) {
        Blank()
        SlideIndicator({
          icon: $r('sys.symbol.play_round_triangle'),
          title: $r('app.string.scroll_to_go_player'),
          h: this.SlideToPlayIndicatorHeight,
          alignItem: VerticalAlign.Top,
          maxH: SLIDE_BAR_MAXH
        })
      } else {
        SlideIndicator({
          icon: this.slideUpToMain ? $r('sys.symbol.house_fill') : $r('sys.symbol.backward_end_fill'),
          title: this.slideUpToMain ? $r('app.string.scroll_to_go_explore') : $r('app.string.scroll_to_play_prev'),
          h: this.SlideToHouseIndicatorHeight,
          alignItem: VerticalAlign.Bottom,
          maxH: SLIDE_BAR_MAXH
        })
        SlideIndicator({
          icon: $r('sys.symbol.forward_end_fill'),
          title: $r('app.string.scroll_to_play_next'),
          h: this.SlideToPlayIndicatorHeight,
          alignItem: VerticalAlign.Top,
          maxH: SLIDE_BAR_MAXH
        })
      }
    }.height('100%').justifyContent(FlexAlign.SpaceBetween)
    .padding({top: Math.max(this.gs.wd.top, 12) + 12, bottom: 24, left: 24, right: 24})
    .hitTestBehavior(HitTestMode.Transparent)
    // .animation({duration: 500})
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
            ForEach(this.swiperArr, (index: number) => {
              this.SwiperItem(index)
            })
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
      })
      .onAreaChange(() => {
        this.onRightHandMode()
      })
      .height('100%')
      .linearGradientBlur(Math.abs(this.slideBlurPer) * 64, {
        direction: this.slideBlurPer > 0 ? GradientDirection.Top : GradientDirection.Bottom,
        fractionStops: [[0, 0], [0, 0.33], [1, 0.66], [1, 1]]
      })
      .animation({duration: 500})
      this.SlideToPlayIndicator()
    }.backgroundColor(Color.Black)
  }

  @Monitor('gs.pref.playerRightHand')
  onRightHandMode() {
    if (this.gs.pref.playerRightHand && !ResponsiveUtil.widthCheck(['sm'])) {
      this.swiperArr = [1, 0]
    } else {
      this.swiperArr = [0, 1]
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

  @Local slideGesOffset: number = 0
  @Local slideUpToMain: boolean = true

  onPrepareSlideToPlay(dir: number) {
    if (this.showExplore) {
      // 仅向上滑动
      this.slideGesOffset = dir < 0 ? -1 : 0
    } else {
      this.slideGesOffset = dir > 0 ? 1 : -1
    }
  }
  onSlideToPlay(offset: number) {
    if (this.slideGesOffset === 0) return;
    if (offset / (this.slideGesOffset) > 0) {
      this.slideGesOffset = offset
      this.slideBlurPer = Math.max(this.SlideToPlayIndicatorHeight, this.SlideToHouseIndicatorHeight) / SLIDE_BAR_MAXH * Math.sign(this.slideGesOffset)
    }
    if (this.SlideToHouseIndicatorHeight >= SLIDE_BAR_MAXH * 2.4 && GlobalStore.pref.swipeToNextTrack) {
      this.slideUpToMain = false
    } else {
      this.slideUpToMain = true
    }
  }
  onSlideToPlayFinish() {
    Logger.debug(`offset = ${this.slideGesOffset}`)
    if (this.slideGesOffset === 0) return;
    // Play Next
    if (this.SlideToPlayIndicatorHeight >= SLIDE_BAR_MAXH) {
      if (this.showExplore) {
        this.showExplore = !this.showExplore
        this.slideGesOffset = 0
      } else {
        PlayControl.playNext()
          .then((res) => {
            if (res !== false) {
              SnackBarUtils.showMessageWithAction(this.hdsSnackBar, {
                icon: $r('sys.symbol.forward_end_fill'),
                message: $r('app.string.start_playing_next'),
              }, {
                title: $r('app.string.common_undo'),
                action: () => {
                  PlayControl.playPre()
                  this.hdsSnackBar.dismiss()
                }
              })
            }
          })
      }
    }
    // Open Explore
    if (this.SlideToHouseIndicatorHeight >= SLIDE_BAR_MAXH) {
      if (this.slideUpToMain) {
        this.showExplore = true
        this.slideGesOffset = 0
      } else {
        PlayControl.playPre().then((res) => {
          if (res !== false) {
            SnackBarUtils.showMessageWithAction(this.hdsSnackBar, {
              icon: $r('sys.symbol.backward_end_fill'),
              message: $r('app.string.start_playing_previous'),
            }, {
              title: $r('app.string.common_undo'),
              action: () => {
                PlayControl.playNext()
                this.hdsSnackBar.dismiss()
              }
            })
          }
        })
        this.hdsSnackBar.dismiss()
      }
    }

    // finally
    if (this.slideGesOffset !== 0) {
      this.getUIContext().animateTo({
        duration: 500
      }, () => {
        this.slideGesOffset = 0
      })
    }

    this.slideBlurPer = 0
    this.slideUpToMain = true
  }

  registerGestureShare() {

    const gestureCallback = () => {
      if (GlobalStore.pref.fistGesture === 0) {
        DialogUtils.showPlayPauseDialog1sec(NowPlayingStore.isPaused)
        PlayControl.playOrPause()
      } else {
        DialogUtils.showHeartDialog1sec(!NowPlayingStore.isLiked)
        SongLike.likeThisSong((icon, msg) => {
          SnackBarUtils.showMessage(this.hdsSnackBar, icon, msg)
        })
      }
    }

    const callback: ApplicationStateChangeCallback = {
      onApplicationForeground() {
        harmonyShare.on("gesturesShare", gestureCallback)
      },
      onApplicationBackground() {
        // 注册后台监听，切回后台不再分享，并关闭弹窗
        harmonyShare.off("gesturesShare", gestureCallback)
      }
    }
    this.getUIContext().getHostContext()!.getApplicationContext()
      .on("applicationStateChange", callback)
    harmonyShare.on("gesturesShare", gestureCallback)
  }
}


@ComponentV2
struct SlideIndicator {
  @Param @Require icon: Resource
  @Param @Require title: ResourceStr
  @Param @Require h: number
  @Param @Require maxH: number
  @Param @Require alignItem: VerticalAlign

  @Local trans: number = 0

  @Monitor('h')
  onHeightChange() {
    if (this.h >= this.maxH) {
      this.trans = (this.h - this.maxH) * 0.3 * (this.alignItem === VerticalAlign.Bottom ? 1 : -1)
    } else {
      this.trans = 0
    }
  }

  get ht() {
    return Math.min(this.h, this.maxH)
  }

  build() {
    Row() {
      Row({space: 24}) {
        SymbolGlyph(this.icon)
          .fontColor([Color.White])
          .fontSize(20)
        Text(this.title)
          .fontColor(Color.White)
          .textShadow({
            radius: 6, color: '#88ffffff'
          })
      }
      .height(this.maxH).clip(true)
    }.width('100%').justifyContent(FlexAlign.Center).alignItems(this.alignItem)
    .backdropBlur(128)
    .backgroundColor($r('app.color.ui_sheet_bg_col'))
    .shadow(ShadowStyle.OUTER_DEFAULT_SM)
    .borderRadius(14)
    .opacity(this.ht / this.maxH)
    .height(this.ht)
    .animation({duration: 100})
    .clip(true)
    .translate({
      y: this.trans
    })
  }
}