import { Album, AlbumAPIUtils, PlayList, PlayListAPIUtils } from "@handwer/api_adapter"
import { SCApp, UserManager, UserStore } from "@handwer/base"
import { WearableMusicLibrarySearchView } from "../views/SearchView"
import { WearableUserCard } from "../components/WearableUserCard"
import { WearableMusicActionPanel, WearableMusicQuickButtons } from "../components/WearableMusicActionPanel"
import { WearableMusicLibraryConfig } from "../config/WearableMusicLibraryConfig"
import { WearableMusicUtils } from "../utils/WearableMusicUtils"
import { DialogHelper } from "@pura/harmony-dialog"
import { LazyData } from "@pie/lazy-data"
import { ArcConst, BackButtonUtils } from "@handwer/wearable_ui_components"
import { ArcList, ArcListItem, promptAction, ArcListAttribute, ArcListItemAttribute } from "@kit.ArkUI"

export function genId_WearableMusicLibraryPlaylist(id: string) {
  return 'WearableMusicLibraryPlaylist_'+id
}

class SnackBarUtils {
  static showMessage(str: ResourceStr) {
    promptAction.openToast({
      message: str
    })
  }
}

@ComponentV2
export struct WearableMusicLibraryMainPage {
  @Consumer(SCApp.wearable_goToPlayer) goToPlayer: () => void = () => {}
  @Consumer(SCApp.settingsSheet) showSettings: boolean = false

  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()
  user = UserStore

  @Local playlistDataSource: LazyData<PlayList> = new LazyData<PlayList>()

  @Local showAlbum: boolean = false
  @Local showSearchPage: boolean = false
  @Local modifyPlaylist: boolean = false
  @Local currentIndex: number = 0

  @Local albums: Album[] = []

  isPlaylistCreated(list: PlayList) {
    return list.userId === this.user.userId
  }

  @Builder PlayList_SingleItem(list: PlayList, index: number) {
    Row() {
      Image(WearableMusicUtils.getOptimizedImageUrl(list.coverImgUrl))
        .width(WearableMusicLibraryConfig.THUMBNAIL_SIZE)
        .height(WearableMusicLibraryConfig.THUMBNAIL_SIZE)
        .borderRadius(WearableMusicLibraryConfig.CARD_RADIUS)
        .draggable(false)
        .margin({ right: 12 })
      
      Column() {
        Text(WearableMusicUtils.truncateText(list.name))
          .maxLines(1)
          .textOverflow({overflow: TextOverflow.Ellipsis})
          .fontSize(WearableMusicLibraryConfig.TITLE_FONT_SIZE)
          .fontWeight(FontWeight.Bold)
          .fontColor(WearableMusicLibraryConfig.PRIMARY_COLOR)
        
        Text(WearableMusicUtils.formatPlaylistInfo(list))
          .fontSize(WearableMusicLibraryConfig.SUBTITLE_FONT_SIZE)
          .fontColor(WearableMusicLibraryConfig.SECONDARY_COLOR)
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.modifyPlaylist) {
        SymbolGlyph(WearableMusicUtils.isUserCreatedPlaylist(list, this.user.userId) ? $r('sys.symbol.xmark') : $r('sys.symbol.heart_square_stack_fill'))
          .fontSize(16)
          .fontColor([WearableMusicLibraryConfig.PRIMARY_COLOR])
      }
    }
    .width('100%')
    .height(WearableMusicLibraryConfig.ITEM_HEIGHT)
    .padding({left: 4, right: 8})
    .backgroundColor(WearableMusicLibraryConfig.BACKGROUND_COLOR)
    .borderRadius(WearableMusicLibraryConfig.CARD_RADIUS)
    .clickEffect({
      level: ClickEffectLevel.LIGHT
    })
    .onClick(() => {
      // if (this.modifyPlaylist) {
      //   this.onRemovePlaylist(index)
      // } else {
      //   this.onPlayListItemClicked(index)
      // }
    })
  }

  @Builder Album_SingleItem(list: Album, index: number) {
    Row() {
      Image(WearableMusicUtils.getOptimizedImageUrl(list.picUrl))
        .width(WearableMusicLibraryConfig.THUMBNAIL_SIZE)
        .height(WearableMusicLibraryConfig.THUMBNAIL_SIZE)
        .borderRadius(WearableMusicLibraryConfig.CARD_RADIUS)
        .draggable(false)
        .margin({ right: 12 })
      
      Column() {
        Text(WearableMusicUtils.truncateText(list.name))
          .maxLines(1)
          .textOverflow({overflow: TextOverflow.Ellipsis})
          .fontSize(WearableMusicLibraryConfig.TITLE_FONT_SIZE)
          .fontWeight(FontWeight.Bold)
          .fontColor(WearableMusicLibraryConfig.PRIMARY_COLOR)
        
        Text(WearableMusicUtils.formatAlbumInfo(list))
          .fontSize(WearableMusicLibraryConfig.SUBTITLE_FONT_SIZE)
          .fontColor(WearableMusicLibraryConfig.SECONDARY_COLOR)
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .height(WearableMusicLibraryConfig.ITEM_HEIGHT)
    .padding({left: 4, right: 8})
    .backgroundColor(WearableMusicLibraryConfig.BACKGROUND_COLOR)
    .borderRadius(WearableMusicLibraryConfig.CARD_RADIUS)
    .clickEffect({
      level: ClickEffectLevel.LIGHT
    })
    .onClick(() => {
      this.onPushAlbum(list)
    })
  }

  @Builder UserInfo() {
    WearableUserCard({
      showAlbum: this.showAlbum,
      onToggleView: () => {
        this.showAlbum = !this.showAlbum
      }
    })
  }

  @Builder ContentList() {
    ArcListItem() {
      this.UserInfo()
    }.width(ArcConst.ARC_LIST_W)
    ArcListItem() {
      WearableMusicQuickButtons()
    }.width(ArcConst.ARC_LIST_W)
    if (this.showAlbum) {
      ForEach(this.albums, (list: Album, index) => {
        ArcListItem() {
          this.Album_SingleItem(list, index)
        }.width(ArcConst.ARC_LIST_W)
      })
    } else {
      LazyForEach(this.playlistDataSource, (list: PlayList, index) => {
        ArcListItem() {
          this.PlayList_SingleItem(list, index)
        }.width(ArcConst.ARC_LIST_W)
      }, (val: PlayList, index) => `${val.id}_${val.coverImgUrl}_${val.name}_${val.trackCount}_${index}`)
    }
  }

  @Builder HeaderButtons() {
    WearableMusicActionPanel({
      onSearchClick: () => {
        this.showSearchPage = !this.showSearchPage
      },
      onSettingsClick: () => {
        this.showSettings = !this.showSettings
      }
    })
  }

  @Builder MainContent() {
    ArcList({initialIndex: 1}) {
      ArcListItem() {
        this.HeaderButtons()
      }.width(ArcConst.ARC_LIST_W)
      this.ContentList()
    }
    .width('100%')
    .height('100%')
    .translate(this.showSearchPage ? {
      y: '20%'
    } : undefined)
    .space(ArcConst.ARC_LIST_SPC)
    .scale(this.showSearchPage ? { x: 0.9, y: 0.9 } : undefined)
    // .foregroundBlurStyle(this.showSearchPage ? BlurStyle.BACKGROUND_REGULAR : undefined)
    .animation(WearableMusicUtils.getWearableAnimationConfig())
    .fadingEdge(true)
  }

  @Builder SearchOverlay() {
    if (this.showSearchPage) {
      WearableMusicLibrarySearchView({
        isSearchAlbum: this.showAlbum,
        closeSearch: () => {
          this.showSearchPage = false
        },
        openPlaylist: (playlist) => {
          this.onPushPlaylist(playlist)
        }
      })
        .transition(TransitionEffect.OPACITY.animation({duration: 300}))
        .backgroundBlurStyle(this.showSearchPage ? BlurStyle.BACKGROUND_THICK: undefined)
        .zIndex(10)
    }
  }

  aboutToAppear(): void {
    this.setData()
    this.fetchAlbums()
    BackButtonUtils.registerBackButton({
      id: 'wearableMusicLibrary_showSearch',
      judge: () => {
        return this.showSearchPage
      },
      action: () => {
        this.showSearchPage = false
      }
    })
    BackButtonUtils.registerBackButton({
      id: 'wearableMusicLibrary_modifyPlaylist',
      judge: () => {
        return this.modifyPlaylist
      },
      action: () => {
        this.modifyPlaylist = false
      }
    })
  }

  fetchAlbums() {
    AlbumAPIUtils.getAllAlbums('alphabeticalByName', 10000)
      .then((res) => {
        this.albums = res
      })
  }

  aboutToDisappear(): void {
    BackButtonUtils.unregisterBackButton('wearableMusicLibrary_showSearch')
    BackButtonUtils.unregisterBackButton('wearableMusicLibrary_modifyPlaylist')
  }

  @Monitor('user.userPlaylists')
  setData() {
    this.playlistDataSource.setData(this.user.userPlaylists)
    this.playlistDataSource.notifyDataReload()
  }

  build() {
    Stack() {
      this.MainContent()
      this.SearchOverlay()
    }
    .height('100%')
    .width('100%')
  }

  onPlayListItemClicked(index: number) {
    this.onPushPlaylist(this.user.userPlaylists[index])
  }

  onCreateNewPlaylist(res: string) {
    const id = DialogHelper.showLoadingDialog()
    PlayListAPIUtils.createPlayList(res, false)
      .then((res): Promise<void> | undefined => {
        if (res) {
          SnackBarUtils.showMessage($r('app.string.create_new_playlist_success'));
          return UserManager.fetchUserPlaylists();
        } else {
          SnackBarUtils.showMessage($r('app.string.create_new_playlist_failed'));
          return
        }
      })
      .catch(() => {
        SnackBarUtils.showMessage($r('app.string.create_new_playlist_failed'));
        return
      })
      .finally(() => {
        DialogHelper.closeDialog(id)
        this.modifyPlaylist = false
      })
  }


  onPushPlaylist(playlist: PlayList) {
    // const params = generatePageParams_PlayListDetail(playlist)
    // const handlePop = (val: PopInfo) => {
    //   const result = val.result as PlaylistDetail_PopReturn
    //   if (result.removed) {
    //     const p = this.user.userPlaylists.findIndex((v) => v.id === playlist.id)
    //     if (p !== -1) this.user.userPlaylists.splice(p, 1)
    //   }
    //   this.setData()
    // }
    //
    // this.pageStack.pushPath({
    //   name: 'PlaylistDetail',
    //   param: params,
    //   onPop: (val) => {
    //     handlePop(val)
    //   }
    // }, true)
  }

  onPushAlbum(album: Album) {
    // const params = generatePageParams_AlbumDetail(album)
    // const handlePop = (val: PopInfo) => {
    //   const result = val.result as Album_PopReturn
    //   if (result.removed) {
    //     const p = this.user.userSubAlbum.findIndex((v) => v.id === album.id)
    //     if (p !== -1) this.user.userSubAlbum.splice(p, 1)
    //   }
    // }
    //
    // this.pageStack.pushPath({
    //   name: 'AlbumDetail',
    //   param: params,
    //   onPop: (val) => {
    //     handlePop(val)
    //   }
    // }, true)
  }
}
