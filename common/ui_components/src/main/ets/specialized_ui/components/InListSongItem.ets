import { Song } from '@handwer/api_adapter'
import { SongConvertUtils } from '@handwer/base'
import { ImageCoverThumbnail } from '../exports'

@ReusableV2
@ComponentV2
export struct InListSongItem {
  @Param @Require songName: string
  @Param @Require songArtist: string
  @Param coverInfo: ResourceStr | undefined = undefined
  @Param compactMode: boolean = false

  @Param @Require onPlay: () => void
  @BuilderParam trailing?: () => void

  build() {
    Row() {
      if (this.coverInfo) {
        ImageCoverThumbnail({
          nowPlayingCoverImg: this.coverInfo
        }).margin(this.compactMode ? undefined : {left: 12, top: 4, bottom: 4})
          // .transition(TransitionEffect.OPACITY.animation({duration: 300}))
      }
      Column() {
        Text(this.songName).fontSize(16).fontWeight(FontWeight.Bold)
          .maxLines(2)
          .songText()
        Text(this.songArtist)
          .fontColor($r('sys.color.font_secondary')).fontSize(14)
          .songText()
      }.alignItems(HorizontalAlign.Start).layoutWeight(1).height('100%').justifyContent(FlexAlign.SpaceAround)
      .padding({left: 12})
      if (this.trailing) {
        this.trailing();
      }
    }.height(56).width('100%').justifyContent(FlexAlign.Start)
    // .padding({left: 12, right: 12})
    .onClick(() => {
      this.onPlay()
    })
    .clickEffect({
      level: ClickEffectLevel.MIDDLE
    })
  }
}

@Extend(Text) function songText() {
  // .layoutWeight(1)
  .fontColor(Color.White)
  .maxLines(1)
  .textOverflow({overflow: TextOverflow.Ellipsis})
  .wordBreak(WordBreak.BREAK_ALL)
}