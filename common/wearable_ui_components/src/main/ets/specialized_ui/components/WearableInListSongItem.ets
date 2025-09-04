import { Song } from '@handwer/api_adapter'
import { SongConvertUtils } from '@handwer/base'
import { WearableImageCover } from './WearableImageCover'

@ReusableV2
@ComponentV2
export struct WearableInListSongItem {
  @Param @Require songName: string
  @Param @Require songArtist: string
  @Param coverInfo: ResourceStr | undefined = undefined
  @Param isPlaying: boolean = false

  @Param @Require onPlay: () => void
  @BuilderParam trailing?: () => void

  build() {
    Row({ space: 12 }) {
      if (this.coverInfo) {
        WearableImageCover({
          nowPlayingCoverImg: this.coverInfo,
          size: 40
        })
      }
      
      Column({ space: 2 }) {
        Text(this.songName)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isPlaying ? $r('app.color.brand_fg') : $r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .textAlign(TextAlign.Start)
        
        Text(this.songArtist)
          .fontSize(12)
          .fontColor(this.isPlaying ? $r('app.color.brand_fg') : $r('sys.color.font_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .textAlign(TextAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceAround)
      
      if (this.trailing) {
        this.trailing();
      }
    }
    .height(48)
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.isPlaying ? $r('app.color.play_list_single_item_bg') : Color.Transparent)
    .borderRadius(12)
    .onClick(() => {
      this.onPlay()
    })
    .clickEffect({
      level: ClickEffectLevel.MIDDLE
    })
  }
}
