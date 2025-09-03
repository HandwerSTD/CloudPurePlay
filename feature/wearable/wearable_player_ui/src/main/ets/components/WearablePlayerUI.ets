import {
  GlobalStore,
  NowPlayingStore, PlayControl,
  PlayQueueStore,
  PlayQueueUtils,
  SCApp,
  SongLike,
  UserStore } from "@handwer/base"
import { PLAYMODE, Song_INITIAL } from "@handwer/api_adapter"
import {  ActionButton, ArcConst, UIComponentUtils} from "@handwer/wearable_ui_components"
import { ArcSwiper, ArcSwiperAttribute, promptAction } from "@kit.ArkUI"
import { ClickUtil } from "@pura/harmony-utils"
import { WearableImageCover } from "./WearableImageCover"
import { WearableEmptyStateView } from "./WearableEmptyStateView"
import { WearableEmptyQueueView } from "./WearableEmptyQueueView"
import { WearablePlayQueueView } from "../views/WearablePlayQueueView"
import { WearableLyricComponent } from "../views/WearableLyricArea"
import { WearablePlaybackControlComponent } from "./WearablePlaybackControlComponent"

const nps = NowPlayingStore

@ComponentV2
export struct MainPage {
  gs = GlobalStore
  user = UserStore
  _nps = NowPlayingStore
  pq = PlayQueueStore

  @Consumer(SCApp.settingsSheet) consoleSheet: boolean = false
  @Provider(SCApp.playQueueSheet) showQueueSheet: boolean = false
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
  // @Builder WearablePlaybackControl() {
  //   Row() { // 手表上使用更紧凑的间距
  //     // 上一曲
  //      ActionButton({
  //       icon: $r('sys.symbol.backward_end_fill'),
  //       customFontColor: [Color.White],
  //       clickAction: () => {
  //         ClickUtil.throttle(() => {
  //           PlayControl.playPre()
  //         }, 500)
  //       },
  //     })
  //
  //     // 播放/暂停 - 中央按钮稍大
  //      ActionButton({
  //       icon: nps.isPlaying && !nps.isPaused ? $r('sys.symbol.pause_fill') : $r('sys.symbol.play_fill'),
  //       customFontColor: [Color.White],
  //       clickAction: () => {
  //         ClickUtil.throttle(() => {
  //           if(nps.isPaused) {
  //             PlayControl.resumeMusic()
  //           } else {
  //             PlayControl.pauseMusic()
  //           }
  //         }, 300)
  //       },
  //     })
  //        // .scale(nps.isPaused ? undefined : {x: 1.3, y: 1.3})
  //        // .animation({duration: 500, curve: Curve.Ease})
  //
  //     // 下一曲
  //      ActionButton({
  //       icon: $r('sys.symbol.forward_end_fill'),
  //       customFontColor: [Color.White],
  //       clickAction: () => {
  //         ClickUtil.throttle(() => {
  //           PlayControl.playNext()
  //         }, 500)
  //       },
  //
  //     })
  //   }
  //   .justifyContent(FlexAlign.SpaceEvenly)
  //   .width('100%')
  // }

  // ---- 手表专用的功能按钮行 ----
  @Builder WearableFunctionButtons() {
    Row({ space: 8 }) { // 减少间距以适应更多按钮
      // 喜欢按钮
       ActionButton({
        icon: nps.isLiked ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'),
         customFontSize: 14,
        customFontColor: nps.isLiked ? [Color.Red] : [Color.White],
        clickAction: () => {
          SongLike.likeThisSong((icon, msg) => {
            promptAction.openToast({message: msg})
          })
        },

      })

      // 循环模式
       ActionButton({
        icon: UIComponentUtils.getQueueCycleModeIcon(PlayQueueStore.cycleMode),
         customFontSize: 14,
        customFontColor: [Color.White],
        clickAction: () => {
          PlayQueueUtils.changeCycleMode()
        },

      })

      // 播放队列
       ActionButton({
        icon: $r('sys.symbol.list_xmark'),
         customFontSize: 14,
        customFontColor: [Color.White],
        clickAction: () => {
          this.showQueueSheet = true
        },
      })
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
        onExploreClick: () => {
        }
      })
    } else {
      Column({ space: 16 }) {

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

  @Builder PlayerUI() {
    Stack() {
      WearableImageCover({
        nowPlayingCoverImg: this.nowPlayingCoverImg,
        resetNewBackgroundColor: (colors: ResourceColor[]) => {
          this.backgroundFlowingColors = colors
        }
      }).foregroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      // 背景渐变
      // Column()
      //   .width('100%')
      //   .height('100%')
      //   .linearGradient({
      //     colors: this.backgroundFlowingColors.map((color, index) => [color, index / (this.backgroundFlowingColors.length - 1)]),
      //     direction: GradientDirection.Bottom
      //   })
      //   .animation({
      //     duration: 2000,
      //     curve: Curve.Ease
      //   })

      // 主内容区域
      this.WearableNowPlayingArea()
    }
    .width(ArcConst.MAX_LEN)
    .height(ArcConst.MAX_LEN)
    .borderRadius('50%')
    .clip(true)
  }
  @Builder LyricUI() {

    Stack() {
      WearableImageCover({
        nowPlayingCoverImg: this.nowPlayingCoverImg,
        resetNewBackgroundColor: (colors: ResourceColor[]) => {
          this.backgroundFlowingColors = colors
        }
      }).foregroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      // 背景渐变
      // Column()
      //   .width('100%')
      //   .height('100%')
      //   .linearGradient({
      //     colors: this.backgroundFlowingColors.map((color, index) => [color, index / (this.backgroundFlowingColors.length - 1)]),
      //     direction: GradientDirection.Bottom
      //   })
      //   .animation({
      //     duration: 2000,
      //     curve: Curve.Ease
      //   })

      WearableLyricComponent()
    }
    .width(ArcConst.MAX_LEN)
    .height(ArcConst.MAX_LEN)
    .borderRadius('50%')
    .clip(true)
  }
  @Builder PlayQueue() {
    WearablePlayQueueView({
      onClose: () => {
        this.showQueueSheet = false
      }
    })
  }

  build() {
    ArcSwiper() {
      WearableImageCover({
        nowPlayingCoverImg: this.nowPlayingCoverImg,
        resetNewBackgroundColor: (colors: ResourceColor[]) => {
          this.backgroundFlowingColors = colors
        }
      })
      this.PlayerUI()
      this.LyricUI()
    }.vertical(true).indicator(false)
    .defaultFocus(true)
    .index(1)
    .width(ArcConst.MAX_LEN)
    .height(ArcConst.MAX_LEN)
    .bindSheet(this.showQueueSheet!!, this.PlayQueue, {
      preferType: SheetType.CENTER,
      backgroundColor: $r('app.color.ui_sheet_bg_col'),
      blurStyle: BlurStyle.BACKGROUND_THICK,
      showClose: false,
    })
  }
}
