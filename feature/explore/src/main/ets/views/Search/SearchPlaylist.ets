import { PlayList, PlayListAPIUtils } from "@handwer/api_adapter"
import { ResponsiveUtil, SCApp, UserStore } from "@handwer/base"
import {
  PlaylistDetail_PopReturn,
  CommonCoverItem,
  CommonCoverItemConversion,
  CommonSongListCard,
  generatePageParams_PlayListDetail,
  LightUpContainer,
  LightUpRoundedButton,
  LightUpDefaultConfig,
  ImageCoverThumbnail} from "@handwer/ui_components"
import { hdsEffect } from "@kit.UIDesignKit"
import { LazyData } from "@pie/lazy-data"
import { LengthMetrics } from "@kit.ArkUI"

@ComponentV2
export struct SearchPlaylistView {
  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()
  @Param @Require searchContent: string
  @Local searchPlaylists: PlayList[] = []
  @Local searchPlaylistsDataSource: LazyData<PlayList> = new LazyData()
  @Local gridCount: number = 1
  @Local fullWindowSizeArea?: Area
  @Local pageOpacity: number = 1
  allPlaylists: PlayList[] = []

  @Builder Playlist_SingleItem(list: PlayList, index: number) {
    ImageCoverThumbnail({
      nowPlayingCoverImg: list.coverImgUrl,
      name: list.name
    })
    .onClick(() => {
      this.onPushPlaylist(list)
    })
  }

  @Builder TitleHeader() {
    Row() {
      Row({space: 12}) {
        SymbolGlyph($r('sys.symbol.music_note_list'))
          .fontColor([Color.White])
          .fontWeight(FontWeight.Bold )
          .fontSize(24)
          .padding(8)
          .backgroundColor($r('app.color.play_list_single_item_bg'))
          .borderRadius(10)
        Text($r('app.string.Playlist'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        if (this.searchPlaylists.length > 0) {
          Divider().vertical(true).color(Color.White).width(1).height(24)
          Text($r('app.string.num_results', this.searchPlaylists.length))
            .fontSize(15)
            .fontColor(Color.White)
        }
      }
    }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    .padding(24)
  }

  @Builder MyPlaylistList() {
    ListItemGroup({space: 36}) {
      LazyForEach(this.searchPlaylistsDataSource, (list: PlayList, index) => {
        ListItem() {
          LightUpContainer({
            lightUpConfig: {
              lightIntensity: 1,
              lightHeight: 240,
            },
            child: () => {
              this.Playlist_SingleItem(list, index)
            }
          })
        }
      }, (val: PlayList, index) => `${val.id}_${val.name}_${val.trackCount}_${index}`)
    }
    .transition(TransitionEffect.OPACITY
      .combine(TransitionEffect.translate({ y: 24 }))
      .animation({ duration: 500, curve: Curve.Friction}))
    .padding({left: 12, right: 12, top: 12})
  }

  aboutToAppear(): void {
    // 获取用户歌单作为搜索基础数据
    this.allPlaylists = UserStore.userPlaylists
    this.search()
  }

  @Monitor('searchContent')
  async search() {
    if (this.searchContent === '') {
      this.searchPlaylists = []
    } else {
      // 首先从用户歌单中搜索
      const localResults = this.allPlaylists.filter((val) => {
        return val.name.toLowerCase().includes(this.searchContent.toLowerCase())
      })
      this.searchPlaylists = localResults
    }
    this.searchPlaylistsDataSource.setData(this.searchPlaylists)
    this.searchPlaylistsDataSource.notifyDataReload()
  }

  onPushPlaylist(playlist: PlayList) {
    const params = generatePageParams_PlayListDetail(playlist)
    const handlePop = (val: PopInfo) => {
      const result = val.result as PlaylistDetail_PopReturn
    }

    this.pageStack.pushPath({
      name: 'PlaylistDetail',
      param: params,
      onPop: (val) => {
        handlePop(val)
      }
    }, true)
  }

  build() {
    NavDestination() {
      Column() {
        if (this.searchPlaylists.length > 0) {
          this.TitleHeader()
          List() {
            this.MyPlaylistList()
            ForEach((new Array(this.gridCount).fill(0)), (_: number) => {
              ListItem().height(12)
            })
          }.width('100%')
          .layoutWeight(1)
          .cachedCount(3 * this.gridCount)
          .lanes(this.gridCount, 24)
          .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
          .fadingEdge(true, {
            fadingEdgeLength: LengthMetrics.percent(10)
          })
          .clip(false)
          .onAreaChange((_, nw) => {
            this.gridCount = ResponsiveUtil.chooseByWidth([2,4,6])
          })
        } else {
          // 空状态占位符
          Column() {
            SymbolGlyph($r('sys.symbol.music_note_list'))
              .fontColor([$r('sys.color.font_on_tertiary')])
              .fontSize(48)
              .margin({bottom: 12})
            Text($r('app.string.common_empty_content'))
              .fontColor($r('sys.color.font_on_tertiary'))
              .fontSize(16)
          }
          .justifyContent(FlexAlign.Center)
          .layoutWeight(1)
          .offset({y: -48})
        }
      }.height('100%').width('100%')
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .opacity(this.pageOpacity)
    .animation({duration: ResponsiveUtil.chooseByWidth([300, 200, 200])})
  }
}