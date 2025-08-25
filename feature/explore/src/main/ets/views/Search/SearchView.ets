import { Album, PlayList, SearchAPIUtils, Song, SongAPIUtils } from "@handwer/api_adapter"
import { CommonCoverItem,
  CommonCoverItemConversion,
  CommonSongListCard, LightUpContainer } from "@handwer/ui_components"
import { hdsEffect } from "@kit.UIDesignKit"
import { LengthMetrics } from "@kit.ArkUI"
import { ResponsiveUtil, UserStore } from "@handwer/base"

@ComponentV2
export struct ExploreSearchView {
  @Param isSearchAlbum: boolean = false
  @Event openPlaylist: (playlist: PlayList) => void
  @Event closeSearch: () => void
  @Local searchContent: string = ''
  @Local gridColumnNum: number = 4

  @Local searchPlaylists: PlayList[] = []
  @Local searchAlbums: Album[] = []


  @Builder Placeholder() {
    Column() {

    } .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
  }

  @Builder ListView() {
    if (this.searchContent === '') {
      this.Placeholder()
    } else {
      List({space: ResponsiveUtil.chooseByWidth([12, 24])}) {
        ListItem() {
          this.SongResult()
        }
        ListItem() {
          this.PlaylistResult()
        }
        ListItem() {
          this.AlbumResult()
        }
      }.width('100%').height('100%')
      .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
      .fadingEdge(true, {
        fadingEdgeLength: LengthMetrics.percent(10)
      })
      .clip(false)
    }
  }

  @Builder SongResult() {
    SongCard({
      searchContent: this.searchContent
    }).transition(TransitionEffect.OPACITY.animation({duration: 300}))
  }

  @Builder PlaylistResult() {
    PlaylistCard({
      searchContent: this.searchContent
    }).transition(TransitionEffect.OPACITY.animation({duration: 300}))
  }

  @Builder AlbumResult() {
    AlbumCard({
      searchContent: this.searchContent
    }).transition(TransitionEffect.OPACITY.animation({duration: 300}))
  }

  build() {
    Column() {
      Search({placeholder: $r('app.string.Search_content')})
        .zIndex(1)
        .id('musicLibrary_SearchComp')
        .margin({top: 12, bottom: 12})
        .onChange((val) => {
          this.searchContent = val
        })
        .width('100%')
        .fontColor(Color.White)
        .placeholderColor(Color.White)
        .cancelButton({
          icon: {
            color: Color.White
          }
        })
        .searchIcon({
          color: Color.White
        })
        .onAppear(() => {
          try {
            this.getUIContext().getFocusController().requestFocus('musicLibrary_SearchComp')
          } catch (error) {
          }
        })
      this.ListView()
    }.height('100%').width('100%').padding({left: 12, right: 12})
    .onClick(() => {
      this.closeSearch()
    })
  }
  onPlayListItemClicked(index: number) {
    this.openPlaylist(this.searchPlaylists[index])
  }
}

@ComponentV2
struct SongCard {
  @Param @Require searchContent: string
  @Local searchSong: CommonCoverItem[] = []

  aboutToAppear(): void {
    this.search()
  }
  build() {
    CommonSongListCard({
      titleIcon: $r('sys.symbol.play_circle_badge_music_note'),
      title: $r('app.string.music_single'),
      items: this.searchSong,
      detailViewPush: () => {

      }
    }).visibility(this.searchSong.length > 0 ? Visibility.Visible : Visibility.None)
  }

  @Monitor('searchContent')
  async search() {
    if (this.searchContent === '') {
      this.searchSong = []
    } else {
      const result = (await SongAPIUtils.getAllSongs()).slice(0, 20)
      this.searchSong = CommonCoverItemConversion.fromSongs(result, (v) => {

      })
    }
  }
}


@ComponentV2
struct PlaylistCard {
  @Param @Require searchContent: string
  @Local searchSong: CommonCoverItem[] = []

  aboutToAppear(): void {
    this.search()
  }

  build() {
    CommonSongListCard({
      titleIcon: $r('sys.symbol.music_note_list'),
      title: $r('app.string.Playlist'),
      items: this.searchSong,
      detailViewPush: () => {

      }
    }).visibility(this.searchSong.length > 0 ? Visibility.Visible : Visibility.None)
  }

  @Monitor('searchContent')
  async search() {

    if (this.searchContent === '') {
      this.searchSong = []
    } else {
      const result = UserStore.userPlaylists.filter((val) => {
        return val.name.toLowerCase().includes(this.searchContent.toLowerCase())
      })
      this.searchSong = CommonCoverItemConversion.fromPlaylist(result, (v) => {

      })
    }
  }
}

@ComponentV2
struct AlbumCard {
  @Param @Require searchContent: string
  @Local searchSong: CommonCoverItem[] = []

  aboutToAppear(): void {
    this.search()
  }
  build() {
    CommonSongListCard({
      titleIcon: $r('sys.symbol.opticaldisc'),
      title: $r('app.string.Album'),
      items: this.searchSong,
      detailViewPush: () => {

      }
    }).visibility(this.searchSong.length > 0 ? Visibility.Visible : Visibility.None)
  }

  @Monitor('searchContent')
  async search() {

    if (this.searchContent === '') {
      this.searchSong = []
    } else {
      const result = UserStore.userSubAlbum.filter((val) => {
        return val.name.toLowerCase().includes(this.searchContent.toLowerCase())
      })
      this.searchSong = CommonCoverItemConversion.fromAlbums(result, (v) => {

      })
    }
  }
}