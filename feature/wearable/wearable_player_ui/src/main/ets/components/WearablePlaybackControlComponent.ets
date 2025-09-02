import { NowPlayingStore, PlayControl } from "@handwer/base"
import { LightUpRoundedButton, LightUpConfig } from "@handwer/ui_components"
import { ClickUtil } from "@pura/harmony-utils"
import { curves } from "@kit.ArkUI"

const nps = NowPlayingStore

const WEARABLE_CONTROL_CONFIG: LightUpConfig = {
  lightIntensity: 1,
  lightHeight: 120,
  lightBloom: 0.2
}

@ComponentV2
export struct WearablePlaybackControlComponent {
  @Param s_size: 'small' | 'medium' | 'large' = 'medium'
  @Param showProgress: boolean = false
  
  get buttonSize(): number {
    switch (this.s_size) {
      case 'small': return 32
      case 'medium': return 40
      case 'large': return 48
      default: return 40
    }
  }

  get centerButtonSize(): number {
    return this.buttonSize + 8
  }

  get spacing(): number {
    switch (this.s_size) {
      case 'small': return 12
      case 'medium': return 16
      case 'large': return 20
      default: return 16
    }
  }

  @Builder PlaybackButtons() {
    Row({ space: this.spacing }) {
      // 上一曲
      LightUpRoundedButton({
        icon: $r('sys.symbol.backward_end_fill'),
        customFontColor: [Color.White],
        clickAction: () => {
          ClickUtil.throttle(() => {
            PlayControl.playPre()
          }, 500)
        },
        lightUpConfig: WEARABLE_CONTROL_CONFIG
      })
      .width(this.buttonSize)
      .height(this.buttonSize)

      // 播放/暂停 - 中央按钮
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
        lightUpConfig: WEARABLE_CONTROL_CONFIG
      })
      .width(this.centerButtonSize)
      .height(this.centerButtonSize)
      .scale(nps.isPlaying && !nps.isPaused ? { x: 1.1, y: 1.1 } : { x: 1, y: 1 })
      .animation({
        duration: 300,
        curve: curves.springMotion()
      })

      // 下一曲
      LightUpRoundedButton({
        icon: $r('sys.symbol.forward_end_fill'),
        customFontColor: [Color.White],
        clickAction: () => {
          ClickUtil.throttle(() => {
            PlayControl.playNext()
          }, 500)
        },
        lightUpConfig: WEARABLE_CONTROL_CONFIG
      })
      .width(this.buttonSize)
      .height(this.buttonSize)
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .width('100%')
  }

  @Builder ProgressBar() {
    if (this.showProgress) {
      Column({ space: 4 }) {
        // 进度条
        Progress({
          value: nps.playTime,
          total: nps.currentSong.duration || 1,
          type: ProgressType.Linear
        })
        .width('90%')
        .height(2)
        .color(Color.White)
        .backgroundColor(Color.Transparent)

        // 时间显示
        Row() {
          Text(this.formatTime(nps.playTime))
            .fontSize(10)
            .fontColor(Color.White)
            .opacity(0.7)

          Blank()

          Text(this.formatTime(nps.currentSong.duration || 0))
            .fontSize(10)
            .fontColor(Color.White)
            .opacity(0.7)
        }
        .width('90%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
  }

  formatTime(milliseconds: number): string {
    const seconds = Math.floor(milliseconds / 1000)
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
  }

  build() {
    Column({ space: 8 }) {
      this.ProgressBar()
      this.PlaybackButtons()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
