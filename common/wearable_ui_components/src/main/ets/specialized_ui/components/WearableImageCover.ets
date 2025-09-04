@ComponentV2
export struct WearableImageCover {
  @Param @Require nowPlayingCoverImg: ResourceStr
  @Param ssize?: number = 80

  build() {
    Stack() {
      Image(this.nowPlayingCoverImg)
        .width(this.ssize)
        .height(this.ssize)
        .draggable(false)
        .borderRadius(12)
        .shadow(ShadowStyle.OUTER_DEFAULT_MD)
        .animation({ duration: 500 })
    }
    .width(this.size)
    .height(this.size)
  }
}
