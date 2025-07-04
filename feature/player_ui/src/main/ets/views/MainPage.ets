import { GlobalStore, ResponsiveUtil } from "@handwer/base"
import { curves } from "@kit.ArkUI"

@ComponentV2
export struct MainPage {
  store = GlobalStore


  @Builder CoverInfo() {

  }

  @Builder PlaybackControl() {

  }

  // -----------------------------------------------

  @Builder NowPlayingArea() {
    Column() {
      this.CoverInfo()
      this.PlaybackControl()
    }
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
}
