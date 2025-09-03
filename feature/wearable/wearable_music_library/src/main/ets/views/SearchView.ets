import { Album, PlayList } from "@handwer/api_adapter"
import { UserStore } from "@handwer/base"
import { WearableMusicLibraryConfig } from "../config/WearableMusicLibraryConfig"
import { WearableMusicUtils } from "../utils/WearableMusicUtils"
import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute } from "@kit.ArkUI"
import { ArcConst } from "@handwer/wearable_ui_components"

@ComponentV2
export struct WearableMusicLibrarySearchView {
  @Param isSearchAlbum: boolean = false
  @Event openPlaylist: (playlist: PlayList) => void
  @Event closeSearch: () => void
  @Local searchContent: string = ''

  @Local searchPlaylists: PlayList[] = []
  @Local searchAlbums: Album[] = []

  @Builder PlayList_SingleItem(list: PlayList, index: number) {
    Row() {
      Image(WearableMusicUtils.getOptimizedImageUrl(list.coverImgUrl))
        .width(WearableMusicLibraryConfig.THUMBNAIL_SIZE)
        .height(WearableMusicLibraryConfig.THUMBNAIL_SIZE)
        .borderRadius(WearableMusicLibraryConfig.CARD_RADIUS)
        .draggable(false)
        .margin({ right: 12 })

      Column() {
        Text(WearableMusicUtils.truncateText(list.name))
          .maxLines(1)
          .textOverflow({overflow: TextOverflow.Ellipsis})
          .fontSize(WearableMusicLibraryConfig.TITLE_FONT_SIZE)
          .fontWeight(FontWeight.Bold)
          .fontColor(WearableMusicLibraryConfig.PRIMARY_COLOR)

        Text(WearableMusicUtils.formatPlaylistInfo(list))
          .fontSize(WearableMusicLibraryConfig.SUBTITLE_FONT_SIZE)
          .fontColor(WearableMusicLibraryConfig.SECONDARY_COLOR)
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .height(WearableMusicLibraryConfig.ITEM_HEIGHT)
    .padding({left: 4, right: 8})
    .backgroundColor(WearableMusicLibraryConfig.BACKGROUND_COLOR)
    .borderRadius(WearableMusicLibraryConfig.CARD_RADIUS)
    .clickEffect({
      level: ClickEffectLevel.LIGHT
    })
    .onClick(() => {
      // if (this.modifyPlaylist) {
      //   this.onRemovePlaylist(index)
      // } else {
      //   this.onPlayListItemClicked(index)
      // }
    })
  }

  @Builder Album_SingleItem(list: Album, index: number) {
    Row() {
      Image(WearableMusicUtils.getOptimizedImageUrl(list.picUrl))
        .width(WearableMusicLibraryConfig.THUMBNAIL_SIZE)
        .height(WearableMusicLibraryConfig.THUMBNAIL_SIZE)
        .borderRadius(WearableMusicLibraryConfig.CARD_RADIUS)
        .draggable(false)
        .margin({ right: 12 })

      Column() {
        Text(WearableMusicUtils.truncateText(list.name))
          .maxLines(1)
          .textOverflow({overflow: TextOverflow.Ellipsis})
          .fontSize(WearableMusicLibraryConfig.TITLE_FONT_SIZE)
          .fontWeight(FontWeight.Bold)
          .fontColor(WearableMusicLibraryConfig.PRIMARY_COLOR)

        Text(WearableMusicUtils.formatAlbumInfo(list))
          .fontSize(WearableMusicLibraryConfig.SUBTITLE_FONT_SIZE)
          .fontColor(WearableMusicLibraryConfig.SECONDARY_COLOR)
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .height(WearableMusicLibraryConfig.ITEM_HEIGHT)
    .padding({left: 4, right: 8})
    .backgroundColor(WearableMusicLibraryConfig.BACKGROUND_COLOR)
    .borderRadius(WearableMusicLibraryConfig.CARD_RADIUS)
    .clickEffect({
      level: ClickEffectLevel.LIGHT
    })
    .onClick(() => {
      // this.onPushAlbum(list)
    })
  }

  @Builder SearchResults() {

      ArcList({initialIndex: 1}) {
        ArcListItem() {
          this.SearchHeader()
        }.width(ArcConst.ARC_LIST_W)
        if (this.searchContent === '') {
          ArcListItem() {
            Column() {
              SymbolGlyph($r('sys.symbol.magnifyingglass'))
                .fontColor([$r('sys.color.font_tertiary')])
                .fontSize(32)
                .margin({bottom: 8})
              Text($r('app.string.search_my_music'))
                .fontColor($r('sys.color.font_tertiary'))
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({bottom: 4})
              Text($r('app.string.search_in_library'))
                .fontColor($r('sys.color.font_tertiary'))
                .fontSize(12)
                .textAlign(TextAlign.Center)
                .opacity(0.8)
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
          }
        } else {
          if (this.isSearchAlbum) {
            if (this.searchAlbums.length === 0) {
              ArcListItem() {
                Column() {
                  Text($r('app.string.common_empty_content'))
                    .fontColor(WearableMusicLibraryConfig.TERTIARY_COLOR)
                    .fontSize(WearableMusicLibraryConfig.TITLE_FONT_SIZE)
                    .textAlign(TextAlign.Center)
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .height(100)
              }
            } else {
              ForEach(WearableMusicUtils.filterSearchResults(this.searchAlbums), (list: Album, index) => {
                ArcListItem() {
                  this.Album_SingleItem(list, index)
                }.width(ArcConst.ARC_LIST_W)
              })
            }
          } else {
            if (this.searchPlaylists.length === 0) {
              ArcListItem() {
                Column() {
                  Text($r('app.string.common_empty_content'))
                    .fontColor(WearableMusicLibraryConfig.TERTIARY_COLOR)
                    .fontSize(WearableMusicLibraryConfig.TITLE_FONT_SIZE)
                    .textAlign(TextAlign.Center)
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .height(100)
              }
            } else {
              ForEach(WearableMusicUtils.filterSearchResults(this.searchPlaylists), (list: PlayList, index) => {
                ArcListItem() {
                  this.PlayList_SingleItem(list, index)
                }.width(ArcConst.ARC_LIST_W)
              })
            }
          }
        }
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .space(ArcConst.ARC_LIST_SPC)
      .fadingEdge(true)
  }

  @Builder SearchHeader() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(16)
          .fontColor([$r('sys.color.font_primary')])
      }
      .backgroundColor($r('app.color.common_card_item_background'))
      .width(32)
      .height(32)
      .onClick(() => {
        this.closeSearch()
      })
      
      Blank().width(8)
      
      TextInput({ placeholder: $r('app.string.Search_content') })
        .layoutWeight(1)
        .height(32)
        .fontSize(14)
        .fontColor(Color.White)
        .placeholderColor($r('sys.color.font_tertiary'))
        .backgroundColor($r('app.color.common_card_item_background'))
        .borderRadius(16)
        .padding({ left: 12, right: 12 })
        .onChange((val) => {
          this.searchContent = val
          this.onSearch()
        })
        .onAppear(() => {
          try {
            this.getUIContext().getFocusController().requestFocus('wearable_musicLibrary_SearchInput')
          } catch (error) {
          }
        })
        .id('wearable_musicLibrary_SearchInput')
    }
    .width('100%')
    .padding(12)
  }

  build() {
    Column() {
      this.SearchResults()
    }
    .height('100%')
    .width('100%')
  }

  onPlayListItemClicked(index: number) {
    this.openPlaylist(this.searchPlaylists[index])
    this.closeSearch()
  }

  onAlbumItemClicked(index: number) {
    // Handle album click - this would need to be implemented similar to playlist
    // For now, just close search
    this.closeSearch()
  }

  onSearch() {
    const searchAlbum = () => {
      if (this.searchContent === '') {
        this.searchAlbums = []
      } else {
        this.searchAlbums = UserStore.userSubAlbum.filter((val) => {
          return val.name.toLowerCase().includes(this.searchContent.toLowerCase())
        })
      }
    }

    const searchList = () => {
      if (this.searchContent === '') {
        this.searchPlaylists = []
      } else {
        this.searchPlaylists = UserStore.userPlaylists.filter((val) => {
          return val.name.toLowerCase().includes(this.searchContent.toLowerCase())
        })
      }
    }

    if (this.isSearchAlbum) {
      searchAlbum()
    } else {
      searchList()
    }
  }
}
