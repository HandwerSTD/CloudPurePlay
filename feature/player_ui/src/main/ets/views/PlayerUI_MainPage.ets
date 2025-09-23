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
import { systemShare } from "@kit.ShareKit"
import { common } from "@kit.AbilityKit"
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
        top: 8, bottom: 8 + BAR_OFFSET})
      .clip(false)
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
      } else {
        // Bottom Bar
        this.NowPlayingArea_Bar()
      }
    } else {
      this.LyricArea()
    }
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
}
