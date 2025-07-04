@ComponentV2
export struct MainPage {

  @Builder CoverInfo() {

  }

  @Builder PlaybackControl() {

  }

  // -----------------------------------------------

  @Builder NowPlayingArea() {

  }

  @Builder LyricArea() {

  }

  build() {
    Row() {
      Column() {
        Flex() {

        }
      }
      .width('100%')
    }
    .height('100%')
  }
}
