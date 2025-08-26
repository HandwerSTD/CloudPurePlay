import { ResponsiveUtil, SongConvertUtils } from "@handwer/base"
import { LightUpRoundedButton } from "../../light_up/LightUpButton"
import { LightUpDefaultConfig } from "../../light_up/LightUpConfig"
import { hdsEffect } from "@kit.UIDesignKit"
import { LengthMetrics } from "@kit.ArkUI"
import { Album, PlayList, Song } from "@handwer/api_adapter"
import { InListSongItem } from "./InListSongItem"

export interface CommonCoverItem {
  picUrl: string
  name: string,
  artist?: string,
  onClick: () => void
}

export class CommonCoverItemConversion {
  static fromSongs(songs: Song[], onClick: (s: Song) => void) {
    return songs.map(v => ({
      name: v.name,
      picUrl: v.album.picUrl,
      artist: SongConvertUtils.getArtists(v.artists),
      onClick: () => {
        onClick(v)
      }
    } as CommonCoverItem))
  }
  static fromAlbums(albums: Album[], onClick: (a: Album) => void) {
    return albums.map(val => ({
      name: val.name,
      picUrl: val.picUrl,
      artist: SongConvertUtils.getArtists(val.artists),
      onClick: () => {
        onClick(val)
      }
    } as CommonCoverItem))
  }
  static fromPlaylist(playlists: PlayList[], onClick: (p: PlayList) => void) {
    return playlists.map(v => ({
      name: v.name,
      picUrl: v.coverImgUrl,
      onClick: () => {
        onClick(v)
      }
    } as CommonCoverItem))
  }
}

@ComponentV2
export struct CommonSongListCard {
  @Param @Require title: ResourceStr
  @Param subtitle: ResourceStr = ''
  @Param @Require titleIcon: Resource
  @Param @Require detailViewPush: () => void
  @Param @Require items: CommonCoverItem[]
  @Param useItemNotCover: boolean = false

  @Param detailIcon: Resource | undefined = undefined

  @Local lanes: number = 1

  @Builder CoverItem(it: CommonCoverItem) {
    Column() {
      Row() {
        Image(it.picUrl).borderRadius(12)
          .draggable(false)
          .shadow(ShadowStyle.OUTER_DEFAULT_XS)
          .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
            illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
          }).buildEffect())
          .clickEffect({
            level: ClickEffectLevel.HEAVY
          })
          .layoutWeight(1)
          .aspectRatio(1)
      }
      Text(it.name)
        .margin(12).maxLines(1).textOverflow({overflow: TextOverflow.Ellipsis})
        .fontSize(12).fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_on_primary'))
    }.width(ResponsiveUtil.chooseByWidth([120, 150]))
    .transition(TransitionEffect.OPACITY.animation({duration: 300}))
    .onClick(() => {
      it.onClick()
    })
  }

  @Builder ListedCoverItem(it: CommonCoverItem) {
    InListSongItem({
      coverInfo: it.picUrl,
      songName: it.name,
      songArtist: it.artist,
      onPlay: () => {
        it.onClick()
      }
    })
      .width(ResponsiveUtil.chooseByWidth(['60%','40%','30%']))
      .clip(false)
  }

  @Monitor('items.length')
  onItemsLengthChange() {
    if (this.items.length > 10) this.lanes = 2;
    else this.lanes = 1;
  }

  aboutToAppear(): void {
    this.onItemsLengthChange()
  }

  build() {
    Column() {
      Row() {
        Row({space: 12}) {
          SymbolGlyph(this.titleIcon)
            .fontColor([Color.White])
            .fontWeight(FontWeight.Bold )
            .fontSize(24)
            .padding(8)
            .backgroundColor($r('app.color.play_list_single_item_bg'))
            .borderRadius(10)
          Text(this.title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          if (this.subtitle !== '') {
            Divider().vertical(true).color(Color.White).width(1).height(24)
            Text(this.subtitle)
              .fontSize(15)
              .fontColor(Color.White)
          }
        }.clip(false)
        LightUpRoundedButton({
          lightUpConfig: LightUpDefaultConfig,
          icon: this.detailIcon ?? $r('sys.symbol.chevron_right'),
          customFontColor: [Color.White],
          customFontSize: (this.detailIcon === undefined ? 30 : undefined),
          customPadding: (this.detailIcon === undefined ? 12 : undefined),
          clickAction: () => {
            this.detailViewPush()
          }
        })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      .padding({left: 24, right: 24, top: 24})
      List({space: 24}) {
        ForEach((new Array(this.lanes).fill(0)), () => {
          ListItem()
        })
        ForEach(this.items, (item: CommonCoverItem) => {
          ListItem() {
            if (this.useItemNotCover) {
              this.ListedCoverItem(item)
            } else {
              this.CoverItem(item)
            }
          }.clip(false)
        })
        ForEach((new Array(this.lanes).fill(0)), () => {
          ListItem()
        })
      }.lanes(this.lanes, 24)
      .padding({top: 24, bottom: 24})
      .animation({duration: 300})
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .fadingEdge(true, {
        fadingEdgeLength: LengthMetrics.percent(10)
      })
      .alignSelf(ItemAlign.Start)
      .clip(false)
    }.width('100%')
    .clip(false)
    // .padding({bottom: 12}).borderRadius(24)
    // .backgroundColor($r('sys.color.comp_background_secondary'))
  }
}