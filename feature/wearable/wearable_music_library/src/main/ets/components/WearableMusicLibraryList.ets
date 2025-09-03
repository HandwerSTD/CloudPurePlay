import { Album, PlayList } from "@handwer/api_adapter"
import { UserStore } from "@handwer/base"

@ComponentV2
export struct WearableMusicLibraryList {
  @Param showAlbum: boolean = false
  @Event onItemClick: (item: PlayList | Album) => void
  @Event onItemAction: (item: PlayList | Album, action: string) => void
  @Param enableActions: boolean = false

  @Builder PlaylistItem(playlist: PlayList) {
    Row() {
      Image(playlist.coverImgUrl)
        .width(36)
        .height(36)
        .borderRadius(6)
        .margin({ right: 8 })
      
      Column() {
        Text(playlist.name)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({overflow: TextOverflow.Ellipsis})
          .fontColor($r('sys.color.font_on_primary'))
        
        Text(`${playlist.trackCount} tracks`)
          .fontSize(10)
          .fontColor($r('sys.color.font_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      if (this.enableActions) {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.ellipsis'))
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
        }
        .backgroundColor(Color.Transparent)
        .width(24)
        .height(24)
        .onClick(() => {
          this.onItemAction(playlist, 'more')
        })
      }
    }
    .width('100%')
    .padding(8)
    .backgroundColor($r('app.color.common_card_item_background'))
    .borderRadius(8)
    .clickEffect({ level: ClickEffectLevel.LIGHT })
    .onClick(() => {
      this.onItemClick(playlist)
    })
  }

  @Builder AlbumItem(album: Album) {
    Row() {
      Image(album.picUrl)
        .width(36)
        .height(36)
        .borderRadius(6)
        .margin({ right: 8 })
      
      Column() {
        Text(album.name)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({overflow: TextOverflow.Ellipsis})
          .fontColor($r('sys.color.font_on_primary'))
        
        Text(album.artist?.name || 'Unknown Artist')
          .fontSize(10)
          .fontColor($r('sys.color.font_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      if (this.enableActions) {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.ellipsis'))
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
        }
        .backgroundColor(Color.Transparent)
        .width(24)
        .height(24)
        .onClick(() => {
          this.onItemAction(album, 'more')
        })
      }
    }
    .width('100%')
    .padding(8)
    .backgroundColor($r('app.color.common_card_item_background'))
    .borderRadius(8)
    .clickEffect({ level: ClickEffectLevel.LIGHT })
    .onClick(() => {
      this.onItemClick(album)
    })
  }

  @Builder EmptyState() {
    Column() {
      SymbolGlyph(this.showAlbum ? $r('sys.symbol.opticaldisc') : $r('sys.symbol.heart_square_stack'))
        .fontSize(32)
        .fontColor($r('sys.color.font_tertiary'))
        .margin({ bottom: 8 })
      
      Text(this.showAlbum ? $r('app.string.no_albums') : $r('app.string.no_playlists'))
        .fontSize(14)
        .fontColor($r('sys.color.font_tertiary'))
        .textAlign(TextAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
    .layoutWeight(1)
  }

  build() {
    if (this.showAlbum) {
      if (UserStore.userSubAlbum.length === 0) {
        this.EmptyState()
      } else {
        List({ space: 6 }) {
          ForEach(UserStore.userSubAlbum, (album: Album) => {
            ListItem() {
              this.AlbumItem(album)
            }
          })
        }
        .width('100%')
        .scrollBar(BarState.Auto)
      }
    } else {
      if (UserStore.userPlaylists.length === 0) {
        this.EmptyState()
      } else {
        List({ space: 6 }) {
          ForEach(UserStore.userPlaylists, (playlist: PlayList) => {
            ListItem() {
              this.PlaylistItem(playlist)
            }
          })
        }
        .width('100%')
        .scrollBar(BarState.Auto)
      }
    }
  }
}
