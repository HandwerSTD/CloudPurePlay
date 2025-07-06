import { GlobalStore, NowPlayingStore, PlayControl, ResponsiveUtil } from "@handwer/base"
import { PLAYMODE, Song_INITIAL } from "@handwer/cloud_api"
import { curves } from "@kit.ArkUI"
import { ClickUtil } from "@pura/harmony-utils"

const nps = NowPlayingStore

@ComponentV2
export struct MainPage {

  get nowPlayingCoverImg() {
    if (nps.currentSong === Song_INITIAL) {
      return $r('sys.media.Celia')
    } else {
      return nps.playMode === PLAYMODE.LOCAL ? nps.currentPic : nps.currentPic + '?param=512y512'
    }
  }

  @Builder CoverInfo() {
    Column() {
      Image(this.nowPlayingCoverImg)
        .aspectRatio(1)
        .height(nps.currentSong.id === 0 ? '70%' : '100%')
        .borderRadius(12)
        .shadow(ShadowStyle.OUTER_FLOATING_SM)
        .scale({ x: nps.isPaused ? 0.9 : 1.0, y: nps.isPaused ? 0.9 : 1.0})
        .animation({ duration: 300, curve: Curve.Smooth })
        .gesture(
          TapGesture({
            count: 2,
          }).onAction(this.handleLike)
        )
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .aspectRatio(1)
    .constraintSize({
      minWidth: 0,
      maxWidth: '100%',
      minHeight: 0,
      maxHeight: 500
    })
  }



  @Builder PlaybackControl() {
    Row() {
      // 上一首
      SymbolGlyph($r('sys.symbol.backward_end_fill')).playControlButton()
        .onClick(() => {
          ClickUtil.throttle(() => {
            PlayControl.playPre()
          }, 500)
        })

      // 暂停、继续
      SymbolGlyph(nps.isPaused ? $r('sys.symbol.play_fill') : $r('sys.symbol.pause_fill')).playControlButton()
        .onClick(() => {
          if(nps.isPaused) {
            PlayControl.resumeMusic()
          } else {
            PlayControl.pauseMusic()
          }
        })

      // 下一首
      SymbolGlyph($r('sys.symbol.forward_end_fill')).playControlButton()
        .onClick(() => {
          ClickUtil.throttle(() => {
            PlayControl.playNext()
          }, 500)
        })
    }
  }

  // -----------------------------------------------

  @Builder NowPlayingArea() {
    Column() {
      this.CoverInfo()
      this.PlaybackControl()
    }.height('100%')
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder LyricArea() {

  }

  build() {
    Row() {
      Column() {
        Swiper() {
          this.NowPlayingArea()
          this.LyricArea()
        }.vertical(false)
        .displayCount(ResponsiveUtil.widthCheck(['md','lg','xl']) ? 2 : 1)
        .animation({
          curve: curves.springMotion()
        })
      }
      .width('100%')
    }
    .height('100%')
  }

  async handleLike() {

  }
}

@Extend(SymbolGlyph) function playControlButton() {
  .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.8 })
  .width(30)
  .fontColor([Color.White])
  .draggable(false)
}