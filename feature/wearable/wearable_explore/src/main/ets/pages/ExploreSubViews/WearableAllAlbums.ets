import { Album, AlbumAPIUtils } from "@handwer/api_adapter"
import { ResponsiveUtil, SCApp } from "@handwer/base"
import { LazyData } from "@pie/lazy-data"
import { LengthMetrics } from "@kit.ArkUI"

@ComponentV2
export struct WearableAllAlbums {
  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()
  @Local fullWindowSizeArea?: Area
  @Local pageOpacity: number = 1

  @Local allAlbums: Album[] = []
  @Local allAlbumsDataSource: LazyData<Album> = new LazyData()

  @Builder Album_SingleItem(list: Album, index: number) {
    Row({ space: 12 }) {
      // 专辑封面
      Image(list.picUrl)
        .width($r('app.float.wearable_album_cover_size'))
        .height($r('app.float.wearable_album_cover_size'))
        .borderRadius(8)
        .draggable(false)
        .shadow(ShadowStyle.OUTER_DEFAULT_XS)

      // 专辑信息
      Column({ space: 4 }) {
        Text(list.name)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
        
        Text(list.artists ? list.artists[0].name : '')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius(12)
    .margin({ left: 8, right: 8, bottom: 8 })
    .onClick(() => {
      this.onPushAlbum(list)
    })
  }

  @Builder AlbumGrid() {
    List({ space: 0 }) {
      ForEach(this.allAlbums, (item: Album, index: number) => {
        ListItem() {
          this.Album_SingleItem(item, index)
        }
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Auto)
    .edgeEffect(EdgeEffect.Fade)
  }

  onPushAlbum(album: Album) {
    // 适配可穿戴设备的专辑详情页导航
    this.pageStack.pushPathByName('AlbumDetail', [album])
  }

  aboutToAppear() {
    this.requestAllAlbums()
  }

  async requestAllAlbums() {
    try {
      const result = await AlbumAPIUtils.getAllAlbums('newest') // 限制数量以适应可穿戴设备性能
      this.allAlbums = result
      this.allAlbumsDataSource.setData(this.allAlbums)
    } catch (error) {
      console.error('获取专辑列表失败:', error)
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 专辑列表
        this.AlbumGrid()
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'))
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .opacity(this.pageOpacity)
    .animation({ duration: 300 })
  }
}
