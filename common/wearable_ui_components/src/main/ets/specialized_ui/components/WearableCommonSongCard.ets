import { ResponsiveUtil, SongConvertUtils } from "@handwer/base"
import { LengthMetrics } from "@kit.ArkUI"
import { Album, PlayList, Song } from "@handwer/api_adapter"

export interface WearableCommonCoverItem {
  picUrl: string
  name: string,
  artist?: string,
  onClick: () => void
}

export class WearableCommonCoverItemConversion {
  static fromSongs(songs: Song[], onClick: (s: Song) => void) {
    return songs.map(v => ({
      name: v.name,
      picUrl: v.album.picUrl,
      artist: SongConvertUtils.getArtists(v.artists),
      onClick: () => {
        onClick(v)
      }
    } as WearableCommonCoverItem))
  }
  
  static fromAlbums(albums: Album[], onClick: (a: Album) => void) {
    return albums.map(val => ({
      name: val.name,
      picUrl: val.picUrl,
      artist: SongConvertUtils.getArtists(val.artists),
      onClick: () => {
        onClick(val)
      }
    } as WearableCommonCoverItem))
  }
  
  static fromPlaylist(playlists: PlayList[], onClick: (p: PlayList) => void) {
    return playlists.map(v => ({
      name: v.name,
      picUrl: v.coverImgUrl,
      onClick: () => {
        onClick(v)
      }
    } as WearableCommonCoverItem))
  }
}

@ComponentV2
export struct WearableCommonSongListCard {
  @Param @Require title: ResourceStr
  @Param @Require items: WearableCommonCoverItem[]
  @Local gridColumnNum: number = 2

  @Builder CoverItem(item: WearableCommonCoverItem, index: number) {
    Column({ space: 6 }) {
      Image(item.picUrl)
        .width(60)
        .height(60)
        .borderRadius(8)
        .draggable(false)
        .shadow(ShadowStyle.OUTER_DEFAULT_XS)
        .onClick(item.onClick)
      
      Text(item.name)
        .fontSize(11)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
      
      if (item.artist) {
        Text(item.artist)
          .fontSize(10)
          .fontColor($r('sys.color.font_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }

  build() {
    if (this.items && this.items.length > 0) {
      Column({ space: 8 }) {
        // 标题
        Row() {
          Text(this.title)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .padding({ left: 16, right: 16 })

        // 网格内容
        Grid() {
          ForEach(this.items.slice(0, 6), (item: WearableCommonCoverItem, index: number) => {
            GridItem() {
              this.CoverItem(item, index)
            }
          })
        }
        .columnsTemplate(`repeat(${this.gridColumnNum}, 1fr)`)
        .rowsGap(8)
        .columnsGap(8)
        .padding({ left: 16, right: 16 })
        .height(this.items.length > 2 ? 200 : 100)
      }
      .width('100%')
    }
  }
}
