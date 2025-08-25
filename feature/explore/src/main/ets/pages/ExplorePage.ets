import { Album, AlbumAPIUtils, PlayList, PlayListSong, Song, SongAPIUtils, TopListAPIUtils, PLAYMODE } from "@handwer/api_adapter"
import { UserStore, ResponsiveUtil, SCApp, FeaturedPlayUtils, NowPlayingStore, GlobalStore,
  PlayQueueUtils,
  SongConvertUtils,
  PlayControl,
  SpecialPlayMode,
  Logger,
  SCEmitter,
  ThemeManager} from "@handwer/base"
import { LightUpContainer, HDS_TITLE_CONFIG_STYLE, generatePageParams_AlbumDetail,
  Album_PopReturn,
  BackButtonUtils,
LightUpIconTextButton,
LightUpDefaultConfig,
  SnackBarUtils,UIComponentUtils,
  LightUpRoundedButton,
  generatePageParams_PlayListDetail,
  PlaylistDetail_PopReturn, CommonSongListCard as SubCard, CommonCoverItem} from "@handwer/ui_components"
import { hdsEffect, HdsNavigation, IconStyleMode, HdsNavigationTitleMode, HdsSnackBar, HdsNavigationAttribute } from "@kit.UIDesignKit"
import { LengthMetrics, curves } from "@kit.ArkUI"
import { LazyData } from "@pie/lazy-data"
import { ExploreSearchView } from "../views/Search/SearchView"
import { EmitterUtil } from "@pura/harmony-utils"


@ComponentV2
export struct ExplorePage {
  @Consumer(SCApp.shouldDisableTab) shouldDisableTab: boolean = false

  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()
  @Consumer(SCApp.settingsSheet) settingsSheet: boolean = false
  user = UserStore
  snack = new HdsSnackBar(this.getUIContext())

  @Local playlistDataSource: LazyData<PlayList> = new LazyData<PlayList>()

  @Local showAlbum: boolean = false
  @Local showSearchPage: boolean = false
  @Local modifyPlaylist: boolean = false
  @Local fullWidth: number = 0


  @Builder QuickButtons() {
    Row() {
      List({space: ResponsiveUtil.chooseByWidth([6, 12])}) {
        ListItem().width(0)
        // HeartMode
        ListItem() {
          LightUpIconTextButton({
            icon: $r('sys.symbol.opticaldisc_badge_heart'),
            title: $r('app.string.Heart_list'),
            lightUpConfig: LightUpDefaultConfig,
            clickAction: () => {
              FeaturedPlayUtils.playHeartMode((icon, msg) => {
                SnackBarUtils.showMessage(this.snack, icon, msg)
              })
            }
          })
        }.margin({right: 12})

        ListItem() {
          LightUpIconTextButton({
            icon: UIComponentUtils.getTodayIcon(),
            title: $r('app.string.Daily_recommend'),
            lightUpConfig: LightUpDefaultConfig,
            clickAction: () => {
              FeaturedPlayUtils.playDailySongs((icon, msg) => {
                SnackBarUtils.showMessage(this.snack, icon, msg)
              }, UIComponentUtils.getTodayIcon())
            }
          })
        }.margin({right: 12})

        ListItem() {
          LightUpIconTextButton({
            icon: $r('sys.symbol.radiostation'),
            title: $r('app.string.Personal_fm'),
            lightUpConfig: LightUpDefaultConfig,
            clickAction: () => {
              FeaturedPlayUtils.playPersonalizedFM((icon, msg) => {
                SnackBarUtils.showMessage(this.snack, icon, msg)
              })
            }
          })
        }.margin({right: 12})
        ListItem().width(0)
      }.fadingEdge(true, {
        fadingEdgeLength: LengthMetrics.percent(10)
      })
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
    }.width('100%').justifyContent(FlexAlign.Center)
  }

  @Builder RecommendPlaylist() {
    RecommendPlaylistCard()
  }

  @Builder RecommendForYou() {
    RecommendForYouCard()
  }

  @Builder AllAlbums() {
    AllAlbumsCard()
  }


  @Builder MyContent() {
    List({space: ResponsiveUtil.chooseByWidth([12, 24])}) {
      ForEach((new Array(1).fill(0)), (_: number) => {
        ListItem().height($r('sys.float.ohos_id_navigation_bar_height_emphasize'))
      })
      ListItem() {
        this.QuickButtons()
      }
      ListItem() {
        this.RecommendPlaylist()
      }
      ListItem() {
        this.RecommendForYou()
      }
      ListItem() {
        this.AllAlbums()
      }
    }.width('100%').height('100%')
    .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
    .fadingEdge(true, {
      fadingEdgeLength: LengthMetrics.percent(10)
    })
    .clip(false)
    .onAreaChange((_, nw) => {
      // this.gridColumnNum = ResponsiveUtil.chooseByWidth([2,4,6])
      this.fullWidth = nw.width.valueOf() as number
    })
  }
  @Builder Search() {
    Column() {
      if (this.showSearchPage) {
        ExploreSearchView({
          isSearchAlbum: this.showAlbum,
          closeSearch: () => {
            this.showSearchPage = false
          },
          openPlaylist: (playlist) => {
            // this.onPushPlaylist(playlist)
          }
        })
          .transition(TransitionEffect.OPACITY.animation({duration: 500}))
      }
    }.width('100%').height('100%')
    .hitTestBehavior(this.showSearchPage ? HitTestMode.Default : HitTestMode.None)
  }
  @Builder ExploreMainPage() {
    Column() {
      HdsNavigation() {
        Stack({alignContent: Alignment.BottomEnd}) {
          this.MyContent()
        }.width('100%').height('100%')
      }.width('100%').height('100%').titleBar({
        style: HDS_TITLE_CONFIG_STYLE,
        content: {
          title: {
            mainTitle: $r('app.string.Explore'),
          },
          menu: {
            value: [{
              content: {
                icon: $r('sys.symbol.magnifyingglass'),
                type: IconStyleMode.NORMAL,
                action: () => {
                  this.showSearchPage = !this.showSearchPage
                }
              },
            }]
          }
        },
      }).titleMode(HdsNavigationTitleMode.FREE).mode(NavigationMode.Stack)
      .translate(this.showSearchPage ? {
        y: '15%'
      } : undefined)
      .animation({curve: curves.springMotion(0.6, 0.7)})
    }
    .width('100%').height('100%')
    .foregroundBlurStyle(this.showSearchPage ? BlurStyle.COMPONENT_ULTRA_THIN : undefined, {
      colorMode: ThemeColorMode.DARK,
      scale: 0.5
    })
    .animation({duration: 300})
  }

  aboutToAppear(): void {
    BackButtonUtils.registerBackButton({
      id: 'explore_showSearch',
      judge: () => {
        return this.showSearchPage
      },
      action: () => {
        this.showSearchPage = false
      }
    })
  }
  aboutToDisappear(): void {
    BackButtonUtils.unregisterBackButton('explore_showSearch')
  }

  build() {
    Stack() {
      this.ExploreMainPage()
      this.Search()
    }
  }

  @Monitor('showSearchPage')
  onShowSearch() {
    this.shouldDisableTab = this.showSearchPage
  }

}

@ComponentV2
struct AllAlbumsCard {
  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()

  @Local allAlbums: CommonCoverItem[] = []

  user = UserStore

  aboutToAppear(): void {
    EmitterUtil.onSubscribe(SCEmitter.UserInfoReInit, () => {
      this.loadData()
    })
    this.loadData()
  }
  aboutToDisappear(): void {
    EmitterUtil.unSubscribe(SCEmitter.UserInfoReInit)
  }

  build() {
    SubCard({
      title: $r('app.string.all_albums'),
      titleIcon: $r('sys.symbol.opticaldisc'),
      items: this.allAlbums,
      detailViewPush: () => {
        this.pageStack.pushPathByName('AllAlbums', [])
      }
    })
  }

  loadData() {
    AlbumAPIUtils.getAllAlbums("newest")
      .then((res) => {
        this.allAlbums = res.map(val => ({
          name: val.name,
          picUrl: val.picUrl,
          onClick: () => {
            this.onPushAlbum(val)
          }
        } as CommonCoverItem))
      })
  }

  onPushAlbum(album: Album) {
    const params = generatePageParams_AlbumDetail(album)
    const handlePop = (val: PopInfo) => {
      const result = val.result as Album_PopReturn
      if (result.removed) {
        const p = this.user.userSubAlbum.findIndex((v) => v.id === album.id)
        if (p !== -1) this.user.userSubAlbum.splice(p, 1)
      }
    }

    this.pageStack.pushPath({
      name: 'AlbumDetail',
      param: params,
      onPop: (val) => {
        handlePop(val)
      }
    }, true)
  }
}

@ComponentV2
struct RecommendPlaylistCard {
  user = UserStore

  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()

  @Local songs: CommonCoverItem[] = []

  aboutToAppear(): void {
    EmitterUtil.onSubscribe(SCEmitter.UserInfoReInit, () => {
      setTimeout(() => {
        this.loadData()
      }, 1000)
    })
    setTimeout(() => {
      this.loadData()
    }, 1000)
  }
  aboutToDisappear(): void {
    EmitterUtil.unSubscribe(SCEmitter.UserInfoReInit)
  }

  build() {
    SubCard({
      title: $r('app.string.recommend_for_you'),
      titleIcon: $r('sys.symbol.music_note_list'),
      subtitle: $r('app.string.Playlist'),
      detailIcon: $r('sys.symbol.arrow_2_circlepath'),
      items: this.songs,
      detailViewPush: () => {
        this.loadData()
      }
    })
  }

  loadData() {
    const result = this.user.userPlaylists.filter(() => {
      const prob = Math.min(1, 16/this.user.userPlaylists.length)
      return Math.random() < prob;
    }).map(v => ({
      name: v.name,
      picUrl: v.coverImgUrl,
      onClick: () => {
        this.onPushPlaylist(v)
      }
    } as CommonCoverItem)).sort(() => Math.random() - 0.5)
    this.getUIContext().animateTo({curve: curves.springMotion(0.5, 0.8)}, () => {
      this.songs = result
    })
  }

  onPushPlaylist(playlist: PlayList) {
    const params = generatePageParams_PlayListDetail(playlist)
    const handlePop = (val: PopInfo) => {
      const result = val.result as PlaylistDetail_PopReturn
      if (result.removed) {
        const p = this.user.userPlaylists.findIndex((v) => v.id === playlist.id)
        if (p !== -1) this.user.userPlaylists.splice(p, 1)
        this.loadData()
      }
    }

    this.pageStack.pushPath({
      name: 'PlaylistDetail',
      param: params,
      onPop: (val) => {
        handlePop(val)
      }
    }, true)
  }
}

@ComponentV2
struct RecommendForYouCard {
  user = UserStore

  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()

  _songs: Song[] = []
  @Local songs: CommonCoverItem[] = []

  aboutToAppear(): void {
    EmitterUtil.onSubscribe(SCEmitter.UserInfoReInit, () => {
      this.loadData()
    })
    this.loadData()
  }
  aboutToDisappear(): void {
    EmitterUtil.unSubscribe(SCEmitter.UserInfoReInit)
  }

  build() {
    SubCard({
      title: $r('app.string.recommend_for_you'),
      titleIcon: $r('sys.symbol.lightbulb_max'),
      subtitle: $r('app.string.music_single'),
      items: this.songs,
      detailIcon: $r('sys.symbol.play'),
      detailViewPush: () => {
        this.playFullList()
      }
    })
  }

  loadData() {
    SongAPIUtils.getRandomSongs(20)
      .then((res) => {
        this._songs = res
        this.songs = res.map((v, index) => ({
          name: v.name,
          picUrl: v.album.picUrl,
          onClick: () => {
            this.playSingle(index)
          }
        } as CommonCoverItem))
      })
  }
  async playSingle(songIndex: number) {
    if (this._songs[songIndex].id === NowPlayingStore.currentSong.id) {
      return;
    }
    try {
      const title = this.getUIContext().getHostContext()!.resourceManager.getStringByNameSync('top_played')
      const playName = (songIndex ? this._songs[songIndex].name : title)
      SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.music_note_list'), $r('app.string.start_playing_le_NAME_ge_', playName))

      const song = this._songs[songIndex]
      await PlayQueueUtils.queueAdd(PLAYMODE.SINGLE, song, SongConvertUtils.getArtists(song.artists), '', song.album.picUrl)
      await PlayControl.playNext()

      NowPlayingStore.specialPlayMode = SpecialPlayMode.DISABLED
    } catch (e) {
      Logger.error(`play full list failed: ${JSON.stringify(e)}`)
      SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.music_note_list'), $r('app.string.start_playing_failed'))
    }
  }
  async playFullList(songIndex?: number) {
    if (songIndex) {
      if (this._songs[songIndex].id === NowPlayingStore.currentSong.id) {
        return;
      }
    }
    try {
      const title = this.getUIContext().getHostContext()!.resourceManager.getStringByNameSync('recommend_for_you')
      const playName = (songIndex ? this._songs[songIndex].name : title)
      SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.music_note_list'), $r('app.string.start_playing_le_NAME_ge_', playName))
      const queue = PlayQueueUtils.makeQueueByPlaylist(this._songs.map((v): PlayListSong => {
        return SongConvertUtils.NormalSong2PlaylistSong(v)
      }))
      await PlayQueueUtils.cleanQueue()
      await PlayQueueUtils.queueAddArray(queue)
      await PlayControl.playQueue(songIndex ?? 0)
      NowPlayingStore.specialPlayMode = SpecialPlayMode.DISABLED
    } catch (e) {
      Logger.error(`play full list failed: ${JSON.stringify(e)}`)
      SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.music_note_list'), $r('app.string.start_playing_list_failed'))
    }
  }
}
