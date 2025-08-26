import { Album, PlayList } from "@handwer/api_adapter"
import { LightUpContainer } from "@handwer/ui_components"
import { hdsEffect } from "@kit.UIDesignKit"
import { LengthMetrics } from "@kit.ArkUI"
import { ResponsiveUtil, UserStore } from "@handwer/base"

@ComponentV2
export struct MusicLibrarySearchView {
  @Param isSearchAlbum: boolean = false
  @Event openPlaylist: (playlist: PlayList) => void
  @Event closeSearch: () => void
  @Local searchContent: string = ''
  @Local gridColumnNum: number = 4

  @Local searchPlaylists: PlayList[] = []
  @Local searchAlbums: Album[] = []

  @Builder PlayList_SingleItem(list: PlayList, index: number) {
    Column() {
      Image(list.coverImgUrl).borderRadius(12)
      // .margin({left:12, right: 12, top: 12})
        .draggable(false)
        .shadow(ShadowStyle.OUTER_DEFAULT_XS)
        .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
          illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
        }).buildEffect())
        .clickEffect({
          level: ClickEffectLevel.HEAVY
        })
      Text(list.name)
        .margin(12).maxLines(1).textOverflow({overflow: TextOverflow.Ellipsis})
        .fontSize(12).fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_on_primary'))
    }
    .onClick(() => {
      this.onPlayListItemClicked(index)
    })
    .transition(TransitionEffect.OPACITY.animation({duration: 300}))
  }
  @Builder MyPlayList() {
    if (this.searchPlaylists.length === 0) {
      GridItem() {
        Column() {
          Text($r('app.string.common_empty_content'))
            .fontColor(Color.White)
            .fontSize($r('sys.float.ohos_id_tip_font_size'))
        }
      }.height('50%')
      .columnStart(0).columnEnd(this.gridColumnNum-1)
    } else {
      ForEach(this.searchPlaylists, (list: PlayList, index) => {
        GridItem() {
          LightUpContainer({
            lightUpConfig: {
              lightIntensity: 1,
              lightHeight: 240,
            },
            child: () => {
              this.PlayList_SingleItem(list, index)
            }
          })
        }
      })
    }
  }
  @Builder Album_SingleItem(list: Album, index: number) {
    Column() {
      Image(list.picUrl).borderRadius(12)
      // .margin({left:12, right: 12, top: 12})
        .draggable(false)
        .shadow(ShadowStyle.OUTER_DEFAULT_XS)
        .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
          illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
        }).buildEffect())
        .clickEffect({
          level: ClickEffectLevel.HEAVY
        })
      Text(list.name)
        .margin(12).maxLines(1).textOverflow({overflow: TextOverflow.Ellipsis})
        .fontSize(12).fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_on_primary'))
    }
    .onClick(() => {
      this.onPlayListItemClicked(index)
    })
    .transition(TransitionEffect.OPACITY.animation({duration: 300}))
  }
  @Builder MyAlbum() {
    if (this.searchAlbums.length === 0) {
      GridItem() {
        Column() {
          Text($r('app.string.common_empty_content'))
            .fontColor(Color.White)
            .fontSize($r('sys.float.ohos_id_tip_font_size'))
        }
      }.height('50%')
      .columnStart(0).columnEnd(this.gridColumnNum-1)
    } else {
      ForEach(this.searchAlbums, (list: Album, index) => {
        GridItem() {
          LightUpContainer({
            lightUpConfig: {
              lightIntensity: 1,
              lightHeight: 240,
            },
            child: () => {
              this.Album_SingleItem(list, index)
            }
          })
        }
      })
    }
  }

  @Builder Placeholder() {
    Column() {
      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontColor([$r('sys.color.font_tertiary')])
        .fontSize(48)
        .margin({bottom: 12})
      Text($r('app.string.search_my_music'))
        .fontColor($r('sys.color.font_tertiary'))
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({bottom: 8})
      Text($r('app.string.search_in_library'))
        .fontColor($r('sys.color.font_tertiary'))
        .fontSize(14)
        .textAlign(TextAlign.Center)
        .opacity(0.8)
    } .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
  }

  @Builder ListView() {
    if (this.searchContent === '') {
      this.Placeholder()
    } else {
      Grid() {
        if (this.isSearchAlbum) {
          this.MyAlbum()
        } else {
          this.MyPlayList()
        }
      }.width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .fadingEdge(true, {
        fadingEdgeLength: LengthMetrics.percent(10)
      }).edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
      .padding({left: 12, right: 12})
      // .expandSafeArea([SafeAreaType.SYSTEM])
      .columnsTemplate(new Array(this.gridColumnNum).fill('1fr').join(' '))
      // .animation({duration: 300})
      .rowsGap(36).columnsGap(24)
      .clip(false)
      .onAreaChange((_, nw) => {
        this.gridColumnNum = ResponsiveUtil.chooseByWidth([2,4,6])
      })
    }
  }

  build() {
    Column() {
      Search({placeholder: $r('app.string.Search_content')})
        .zIndex(1)
        .id('musicLibrary_SearchComp')
        .margin({top: 12, bottom: 12})
        .onChange((val) => {
          this.searchContent = val
          this.onSearch()
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