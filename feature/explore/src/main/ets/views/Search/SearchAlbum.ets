import { Album, AlbumAPIUtils } from "@handwer/api_adapter"
import { ResponsiveUtil, SCApp, UserStore } from "@handwer/base"
import {
  Album_PopReturn,
  CommonCoverItem,
  CommonCoverItemConversion,
  CommonSongListCard,
  generatePageParams_AlbumDetail,
  LightUpContainer,
  LightUpRoundedButton,
  LightUpDefaultConfig,
  ImageCoverThumbnail} from "@handwer/ui_components"
import { hdsEffect } from "@kit.UIDesignKit"
import { LazyData } from "@pie/lazy-data"
import { LengthMetrics } from "@kit.ArkUI"

@ComponentV2
export struct SearchAlbumView {
  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()
  @Param @Require searchContent: string
  @Local searchAlbums: Album[] = []
  @Local searchAlbumsDataSource: LazyData<Album> = new LazyData()
  @Local gridCount: number = 1
  @Local fullWindowSizeArea?: Area
  @Local pageOpacity: number = 1
  allAlbums: Album[] = []

  @Builder Album_SingleItem(list: Album, index: number) {
    ImageCoverThumbnail({
      nowPlayingCoverImg: list.picUrl,
      name: list.name
    })
    .onClick(() => {
      this.onPushAlbum(list)
    })
  }

  @Builder TitleHeader() {
    Row() {
      Row({space: 12}) {
        SymbolGlyph($r('sys.symbol.opticaldisc'))
          .fontColor([Color.White])
          .fontWeight(FontWeight.Bold )
          .fontSize(24)
          .padding(8)
          .backgroundColor($r('app.color.play_list_single_item_bg'))
          .borderRadius(10)
        Text($r('app.string.Album'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        if (this.searchAlbums.length > 0) {
          Divider().vertical(true).color(Color.White).width(1).height(24)
          Text($r('app.string.num_results', this.searchAlbums.length))
            .fontSize(15)
            .fontColor(Color.White)
        }
      }
    }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    .padding(24)
  }

  @Builder MyAlbumList() {
    ListItemGroup({space: 36}) {
      LazyForEach(this.searchAlbumsDataSource, (list: Album, index) => {
        ListItem() {
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
      }, (val: Album, index) => `${val.id}_${val.name}_${val.size}_${index}`)
    }
    .transition(TransitionEffect.OPACITY
      .combine(TransitionEffect.translate({ y: 24 }))
      .animation({ duration: 500, curve: Curve.Friction}))
    .padding({left: 12, right: 12, top: 12})
  }

  aboutToAppear(): void {
    AlbumAPIUtils.getAllAlbums('newest')
      .then((res) => {
        this.allAlbums = res
        this.search()
      })
  }

  @Monitor('searchContent')
  async search() {
    if (this.searchContent === '') {
      this.searchAlbums = []
    } else {
      // 首先从用户订阅的专辑中搜索
      const localResults = this.allAlbums.filter((val) => {
        return val.name.toLowerCase().includes(this.searchContent.toLowerCase())
      })
      this.searchAlbums = localResults
    }
    this.searchAlbumsDataSource.setData(this.searchAlbums)
    this.searchAlbumsDataSource.notifyDataReload()
  }

  onPushAlbum(album: Album) {
    const params = generatePageParams_AlbumDetail(album)
    const handlePop = (val: PopInfo) => {
      const result = val.result as Album_PopReturn
    }

    this.pageStack.pushPath({
      name: 'AlbumDetail',
      param: params,
      onPop: (val) => {
        handlePop(val)
      }
    }, true)
  }

  build() {
    NavDestination() {
      Column() {
        if (this.searchAlbums.length > 0) {
          this.TitleHeader()
          List() {
            this.MyAlbumList()
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
            SymbolGlyph($r('sys.symbol.opticaldisc'))
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