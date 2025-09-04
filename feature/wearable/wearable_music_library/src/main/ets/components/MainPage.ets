import { SCApp } from '@handwer/base'
import { WearableAlbumDetail, WearablePlaylistDetail } from '@handwer/wearable_ui_components'
import { WearableMusicLibraryMainPage } from '../pages/MusicLibrary_MainPage'

@ComponentV2
export struct MainPage {
  @Provider(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()

  @Builder pageMap(name: string) {
    if (name === 'PlaylistDetail') {
      WearablePlaylistDetail()
    } else if (name === 'AlbumDetail') {
      WearableAlbumDetail()
    } else if (name === 'Main') {
      this.Destination()
    }
  }

  @Builder Destination() {
    NavDestination() {
      WearableMusicLibraryMainPage()
    }.hideTitleBar(true)
  }

  build() {
    Navigation(this.pageStack, { name: 'Main' } as HomePathInfo) {
    }.navDestination(this.pageMap)
    .mode(NavigationMode.Stack)
    .width('100%').height('100%')
  }
}
