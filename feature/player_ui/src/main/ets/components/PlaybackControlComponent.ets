import { Song_INITIAL } from "@handwer/api_adapter"
import { NowPlayingStore } from "@handwer/base"
import { hdsEffect } from "@kit.UIDesignKit"

@ComponentV2
export struct LightUpProgressBar {

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
            // sourceType: hdsEffect.PointLightSourceType.SOFT,
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