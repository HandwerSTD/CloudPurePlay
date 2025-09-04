import { GlobalStore, SCApp } from "@handwer/base"
import { WearableAlbumDetail, WearablePlaylistDetail } from "@handwer/wearable_ui_components"
import { WearableExplorePage } from "./WearableExplorePage"
import { WearableAllAlbums } from "./ExploreSubViews/WearableAllAlbums"

@ComponentV2
export struct MainPage {
  @Provider(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.pageStack.pushPathByName('Shell', [], false)
  }

  @Builder pageMap(name: string) {
    if (name === 'Shell') {
      WearableMainPage_Shell()
    } else if (name === 'PlaylistDetail') {
      WearablePlaylistDetail()
    } else if (name === 'AlbumDetail') {
      WearableAlbumDetail()
    } else if (name === 'AllAlbums') {
      WearableAllAlbums()
    }
  }

  build() {
    Row() {
      Column() {
        Navigation(this.pageStack) {
          // empty
        }.navDestination(this.pageMap)
        .mode(NavigationMode.Stack)
        .hideTitleBar(true)
        .height('100%')
      }
      .width('100%').height('100%')
    }
    .height('100%')
  }
}

@Builder
export function WearableExplorePageBuilder() {
  MainPage()
}

@ComponentV2
struct WearableMainPage_Shell {
  @Consumer(SCApp.exploreSheet) exploreSheet: boolean = false
  @Consumer(SCApp.settingsSheet) settingsSheet: boolean = false

  @Local pageOpacity: number = 1
  
  gs = GlobalStore

  build() {
    NavDestination() {
      Column() {
        // 可穿戴设备的简化标题栏
        Row() {
          Text($r('app.string.wearable_explore_title'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('100%')
        .height(40)
        .justifyContent(FlexAlign.Center)
        .margin({ top: 8, bottom: 8 })

        // 主要内容区域
        WearableExplorePage()
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'))
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .onBackPressed(() => {
      this.exploreSheet = false;
      return true;
    })
    .opacity(this.pageOpacity)
    .animation({ duration: 300 })
  }
}
