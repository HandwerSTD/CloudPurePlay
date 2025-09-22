import { Album, AlbumAPIUtils } from "@handwer/api_adapter"
import { ResponsiveUtil, SCApp } from "@handwer/base"
import {
  HDS_TITLE_CONFIG_STYLE, LightUpContainer,
  generatePageParams_AlbumDetail,
  Album_PopReturn,
  ImageCoverThumbnail} from "@handwer/ui_components"
import { hdsEffect, HdsNavDestination, HdsNavDestinationAttribute } from "@kit.UIDesignKit"
import { LazyData } from "@pie/lazy-data"
import { LengthMetrics } from "@kit.ArkUI"

@ComponentV2
export struct AllAlbums {
  @Consumer(SCApp.exploreSheet) exploreSheet: boolean = false
  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()
  @Local gridCount: number = 1
  @Local fullWindowSizeArea?: Area
  @Local pageOpacity: number = 1

  @Local allAlbums: Album[] = []
  @Local allAlbumsDataSource: LazyData<Album> = new LazyData()

  @Builder Album_SingleItem(list: Album, index: number) {
    Column() {
      ImageCoverThumbnail({
        nowPlayingCoverImg: list.picUrl,
        name: list.name
      })
    }
    .onClick(() => {
      this.onPushAlbum(list)
    })
  }

  @Builder MyAlbumList() {
    ListItemGroup({space: 36}) {
      LazyForEach(this.allAlbumsDataSource, (list: Album, index) => {
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
    }//.visibility(!this.showAlbum ? Visibility.None : Visibility.Visible)
    .transition(TransitionEffect.OPACITY
      .combine(TransitionEffect.translate({ y: 24 }))
      .animation({ duration: 500, curve: Curve.Friction}))
    .padding({left: 12, right: 12, top: 12})
  }

  aboutToAppear(): void {
    this.loadData()
  }

  build() {
    HdsNavDestination() {
      Column() {
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
      }.height('100%').width('100%')
    }
    .titleBar({
      style: HDS_TITLE_CONFIG_STYLE,
      content: {
        title: {
          mainTitle: $r('app.string.all_albums')
        }
      }
    })
    .onBackPressed(() => {
      if (!this.exploreSheet) {
        this.exploreSheet = true;
        return true;
      }
      return false;
    })
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
  async loadData() {
    this.allAlbums = await AlbumAPIUtils.getAllAlbums('newest')
    this.allAlbumsDataSource.setData(this.allAlbums)
    this.allAlbumsDataSource.notifyDataReload()
  }
}