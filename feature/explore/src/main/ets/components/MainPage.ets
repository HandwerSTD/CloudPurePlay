import { SCApp } from "@handwer/base"
import { AlbumDetail, MusicLibrary, PlaylistDetail } from '@handwer/music_library'


@ComponentV2
export struct MainPage {
  @Provider(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.pageStack.pushPathByName('MusicLibrary', [], false)
  }

  @Builder pageMap(name: string) {
    if (name === 'MusicLibrary') {
      MusicLibrary()
    } else if (name === 'PlaylistDetail') {
      PlaylistDetail()
    } else if (name === 'AlbumDetail') {
      AlbumDetail()
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
export function ExplorePageBuilder() {
  MainPage()
}