import { Album, AlbumAPIUtils } from "@handwer/api_adapter"
import { ResponsiveUtil, SCApp, UserStore } from "@handwer/base"
import {
  Album_PopReturn,
  CommonCoverItem,
  CommonCoverItemConversion,
  CommonSongListCard,
  generatePageParams_AlbumDetail,
  LightUpContainer } from "@handwer/ui_components"
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

  @Builder Album_SingleItem(list: Album, index: number) {
    Column() {
      Stack({alignContent: Alignment.BottomEnd}) {
        Image(list.picUrl).borderRadius(12)
          .draggable(false)
          .shadow(ShadowStyle.OUTER_DEFAULT_XS)
          .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
            illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
          }).buildEffect())
          .clickEffect({
            level: ClickEffectLevel.HEAVY
          })
      }
      Text(list.name)
        .margin(12).maxLines(1).textOverflow({overflow: TextOverflow.Ellipsis})
        .fontSize(12).fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_on_primary'))
    }
    .onClick(() => {
      this.onPushAlbum(list)
    })
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
    this.search()
  }

  @Monitor('searchContent')
  async search() {
    if (this.searchContent === '') {
      this.searchAlbums = []
    } else {
      // 首先从用户订阅的专辑中搜索
      const localResults = UserStore.userSubAlbum.filter((val) => {
        return val.name.toLowerCase().includes(this.searchContent.toLowerCase())
      })
      this.searchAlbums = localResults
      
      // 然后从API搜索更多结果
      // try {
      //   const apiResults = await AlbumAPIUtils.searchAlbums(this.searchContent)
      //   // 合并结果，去重
      //   const allResults = [...localResults]
      //   apiResults.forEach(album => {
      //     if (!allResults.some(existing => existing.id === album.id)) {
      //       allResults.push(album)
      //     }
      //   })
      //   this.searchAlbums = allResults.slice(0, 20) // 限制结果数量
      // } catch (e) {
      //   // 如果API搜索失败，仅使用本地结果
      //   this.searchAlbums = localResults
      // }
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
          List() {
            ForEach((new Array(this.gridCount).fill(0)), (_: number) => {
              ListItem().height($r('sys.float.ohos_id_navigation_bar_height'))
            })
            this.MyAlbumList()
            ForEach((new Array(this.gridCount).fill(0)), (_: number) => {
              ListItem().height(12)
            })
          }.width('100%').height('100%')
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
              .fontColor([$r('sys.color.font_tertiary')])
              .fontSize(48)
              .margin({bottom: 12})
            Text($r('app.string.common_empty_content'))
              .fontColor($r('sys.color.font_tertiary'))
              .fontSize(16)
          }
          .justifyContent(FlexAlign.Center)
          .layoutWeight(1)
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