import {
  GlobalStore,
  NowPlayingStore, PlayControl,
  PlayQueueStore,
  PlayQueueUtils,
  SCApp,
  SongLike,
  UserStore } from "@handwer/base"
import { PLAYMODE, Song_INITIAL } from "@handwer/api_adapter"
import { LightUpRoundedButton, LightUpConfig, SnackBarUtils,
  UIComponentUtils} from "@handwer/ui_components"
import { curves } from "@kit.ArkUI"
import { ClickUtil } from "@pura/harmony-utils"
import { HdsSnackBar } from "@kit.UIDesignKit"
import { WearableImageCover } from "./WearableImageCover"
import { WearableEmptyStateView } from "./WearableEmptyStateView"
import { WearableEmptyQueueView } from "./WearableEmptyQueueView"
import { WearablePlayQueueView } from "../views/WearablePlayQueueView"
import { WearableLyricComponent } from "../views/WearableLyricArea"
import { WearablePlaybackControlComponent } from "./WearablePlaybackControlComponent"

const nps = NowPlayingStore

// 手表专用的轻量化光效配置
const WEARABLE_LIGHT_BTN_CONFIG: LightUpConfig = {
  lightIntensity: 1.2,
  lightHeight: 100,
  lightBloom: 0.2
}

const WEARABLE_LIGHT_PLAYBACK_CONFIG: LightUpConfig = {
  lightIntensity: 0.8,
  lightHeight: 150,
  lightBloom: 0.1,
}

@ComponentV2
export struct MainPage {
  hdsSnackBar = new HdsSnackBar(this.getUIContext())
  gs = GlobalStore
  user = UserStore
  _nps = NowPlayingStore
  pq = PlayQueueStore

  @Consumer(SCApp.settingsSheet) consoleSheet: boolean = false
  @Provider(SCApp.playQueueSheet) showQueueSheet: boolean = false
  @Provider(SCApp.exploreSheet) showExplore: boolean = false
  @Provider(SCApp.showAddToPlaylistSheet) showAddToPlaylistSheet: boolean = false

  @Local backgroundFlowingColors: ResourceColor[] = [Color.Black, Color.Blue, Color.Pink]
  @Local isCompactMode: boolean = false // 手表紧凑模式切换
  @Local showLyrics: boolean = false // 显示歌词

  get nowPlayingCoverImg() {
    if (nps.currentSong === Song_INITIAL) {
      return $r('sys.media.Celia')
    } else {
      return nps.playMode === PLAYMODE.LOCAL ? nps.currentPic : nps.currentPic + '?param=256y256' // 手表使用较小的图片
    }
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

  showAddToPlaylist() {
    this.showAddToPlaylistSheet = true
  }

  // ---- 手表专用的简化控制按钮 ----
  @Builder WearablePlaybackControl() {
    Row({ space: 16 }) { // 手表上使用更紧凑的间距
      // 上一曲
      LightUpRoundedButton({
        icon: $r('sys.symbol.backward_end_fill'),
        customFontColor: [Color.White],
        clickAction: () => {
          ClickUtil.throttle(() => {
            PlayControl.playPre()
          }, 500)
        },
        lightUpConfig: WEARABLE_LIGHT_PLAYBACK_CONFIG
      })
      .width(36)
      .height(36)

      // 播放/暂停 - 中央按钮稍大
      LightUpRoundedButton({
        icon: nps.isPlaying && !nps.isPaused ? $r('sys.symbol.pause_fill') : $r('sys.symbol.play_fill'),
        customFontColor: [Color.White],
        clickAction: () => {
          ClickUtil.throttle(() => {
            if(nps.isPaused) {
              PlayControl.resumeMusic()
            } else {
              PlayControl.pauseMusic()
            }
          }, 300)
        },
        lightUpConfig: WEARABLE_LIGHT_PLAYBACK_CONFIG
      })
      .width(48)
      .height(48)

      // 下一曲
      LightUpRoundedButton({
        icon: $r('sys.symbol.forward_end_fill'),
        customFontColor: [Color.White],
        clickAction: () => {
          ClickUtil.throttle(() => {
            PlayControl.playNext()
          }, 500)
        },
        lightUpConfig: WEARABLE_LIGHT_PLAYBACK_CONFIG
      })
      .width(36)
      .height(36)
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .width('100%')
  }

  // ---- 手表专用的功能按钮行 ----
  @Builder WearableFunctionButtons() {
    Row({ space: 8 }) { // 减少间距以适应更多按钮
      // 喜欢按钮
      LightUpRoundedButton({
        icon: nps.isLiked ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'),
        customFontColor: nps.isLiked ? [Color.Red] : [Color.White],
        clickAction: () => {
          SongLike.likeThisSong((icon, msg) => {
            SnackBarUtils.showMessage(this.hdsSnackBar, icon, msg)
          })
        },
        lightUpConfig: WEARABLE_LIGHT_BTN_CONFIG
      })
      .width(28)
      .height(28)

      // 循环模式
      LightUpRoundedButton({
        icon: UIComponentUtils.getQueueCycleModeIcon(PlayQueueStore.cycleMode),
        customFontColor: [Color.White],
        clickAction: () => {
          PlayQueueUtils.changeCycleMode()
        },
        lightUpConfig: WEARABLE_LIGHT_BTN_CONFIG
      })
      .width(28)
      .height(28)

      // 播放队列
      LightUpRoundedButton({
        icon: $r('sys.symbol.list_xmark'),
        customFontColor: [Color.White],
        clickAction: () => {
          this.showQueueSheet = true
        },
        lightUpConfig: WEARABLE_LIGHT_BTN_CONFIG
      })
      .width(28)
      .height(28)

      // 歌词按钮
      LightUpRoundedButton({
        icon: $r('sys.symbol.lyrics_square'),
        customFontColor: [Color.White],
        clickAction: () => {
          this.showLyrics = !this.showLyrics
        },
        lightUpConfig: WEARABLE_LIGHT_BTN_CONFIG
      })
      .width(28)
      .height(28)
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .width('100%')
  }

  // ---- 手表专用的歌曲信息显示 ----
  @Builder WearableSongInfo() {
    Column({ space: 4 }) {
      Text(nps.currentSong.name)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('90%')

      Text(nps.currentArtists)
        .fontSize(12)
        .fontColor(Color.White)
        .opacity(0.8)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('90%')
    }
    .alignItems(HorizontalAlign.Center)
  }

  // ---- 手表主界面布局 ----
  @Builder WearableNowPlayingArea() {
    if (this.shouldShowEmptyState) {
      WearableEmptyStateView({
        hdsSnackBar: this.hdsSnackBar,
        onExploreClick: () => {
          this.showExplore = true
        }
      })
    } else if (this.showLyrics) {
      // 歌词显示模式
      Column({ space: 8 }) {
        // 顶部歌曲信息
        this.WearableSongInfo()
        
        // 歌词区域
        WearableLyricComponent({
          miniMode: false
        })
        .layoutWeight(1)
        .width('100%')
        
        // 底部播放控制
        WearablePlaybackControlComponent({
          s_size: 'small',
          showProgress: false
        })
        
        // 返回按钮
        LightUpRoundedButton({
          icon: $r('sys.symbol.chevron_left'),
          customFontColor: [Color.White],
          clickAction: () => {
            this.showLyrics = false
          },
          lightUpConfig: WEARABLE_LIGHT_BTN_CONFIG
        })
        .height(32)
        .alignSelf(ItemAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding(8)
    } else {
      Column({ space: 16 }) {
        // 封面区域 - 占据主要空间
        WearableImageCover({
          nowPlayingCoverImg: this.nowPlayingCoverImg,
          handleLike: () => {
            SongLike.likeThisSong((icon, msg) => {
              SnackBarUtils.showMessage(this.hdsSnackBar, icon, msg)
            })
          },
          resetNewBackgroundColor: (colors: ResourceColor[]) => {
            this.backgroundFlowingColors = colors
          }
        })
        .layoutWeight(1)
        .width('80%') // 手表上封面不要太大

        // 歌曲信息
        this.WearableSongInfo()

        // 播放控制按钮
        WearablePlaybackControlComponent({
          s_size: 'medium',
          showProgress: true
        })

        // 功能按钮行
        this.WearableFunctionButtons()
      }
      .width('100%')
      .height('100%')
      .padding(12) // 手表上使用较小的内边距
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(HorizontalAlign.Center)
    }
  }

  // ---- 队列空状态 ----
  @Builder s_size() {
    if (this.isQueueEmpty) {
      WearableEmptyQueueView({
        hdsSnackBar: this.hdsSnackBar
      })
    }
  }

  build() {
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          colors: this.backgroundFlowingColors.map((color, index) => [color, index / (this.backgroundFlowingColors.length - 1)]),
          direction: GradientDirection.Bottom
        })
        .animation({
          duration: 2000,
          curve: Curve.Ease
        })

      // 主内容区域
      this.WearableNowPlayingArea()

      // 队列弹窗
      if (this.showQueueSheet) {
        WearablePlayQueueView({
          onClose: () => {
            this.showQueueSheet = false
          }
        })
        .width('95%')
        .height('95%')
        .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.8, y: 0.8 })))
      }
    }
    .width('100%')
    .height('100%')
    .borderRadius('50%') // 手表圆形屏幕适配
    .clip(true)
  }
}
