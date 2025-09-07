import {
  Album_INITIAL,
  PlayList, PlayListAPIUtils, PlayListSong, PlayList_INITIAL,
  PLAYMODE,
  SongAPIUtils } from "@handwer/api_adapter";
import {
  GlobalContext,
  Logger,
  NowPlayingStore,
  PlayControl,
  PlaylistContentUpdateInfo,
  PlayQueueUtils,
  SCApp,
  SCEmitter,
  SCGlobal,
  SongConvertUtils, SongLike,
  PlaySourceData,
  UserManager,
  UserStore } from "@handwer/base";
import { LazyData } from "@pie/lazy-data";
import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute } from "@kit.ArkUI";
import { EmitterUtil } from "@pura/harmony-utils";
import { WearablePlaylistSongViewModel } from "./WearablePlaylistDetailViewmodel";
import { ActionButton, ActionIconTextButton } from "../../../components/ActionButton";
import { ArcCommonListItem } from "../../../components/CommonListItem";
import { ArcConst } from "../../../constants/WearableConstants";
import { SnackBarUtils } from "../../../utils/export";
import { WearableImageCover, WearableInListSongItem } from "../../exports";

const TAG = '[WearablePlaylistDetail]'

@ComponentV2
export struct WearablePlaylistDetail {
  @Local pageOpacity: number = 1;
  @Local playListInfo: PlayList = PlayList_INITIAL;

  nps = NowPlayingStore
  @Local isLoading: boolean = false;
  hasMore: boolean = true;
  currentOffset: number = 0;
  @Consumer(SCApp.showAddToPlaylistSheet) showAddToPlaylistSheet: boolean = false

  @Local fullPlayListDetail: PlayListSong[] = []
  @Local fullPlayListDataSource: LazyData<WearablePlaylistSongViewModel> = new LazyData()

  get isThisHeartList() {
    return this.playListInfo.id === UserStore.userPlaylists[0]?.id ?? ''
  }

  async onStart() {
    this.fullPlayListDetail = new Array(Math.min(100, this.playListInfo.trackCount)).fill({
      name: '', id: "0", al: Album_INITIAL, dt: 0, ar: [], fee: 0
    } as PlayListSong)
    this.fullPlayListDataSource.setData(
      WearablePlaylistSongViewModel.fromPlaylistData(this.fullPlayListDetail)
    )
    this.fullPlayListDataSource.notifyDataReload()
    const info = await PlayListAPIUtils.getPlaylistInfo(this.playListInfo.id)
    this.playListInfo = info
    this.writeToUserStore()
    await this.loadSongs(200, 0)
    await this.loadSongs(this.playListInfo.trackCount, 200)
  }

  isSongLiked(song: PlayListSong): boolean {
    return SongLike.isSongLiked(song.id)
  }

  @Builder PlayListItemTrailing(song: PlayListSong) {
    ActionButton({
      icon: !this.isSongLiked(song) ?  $r('sys.symbol.heart') : $r('sys.symbol.heart_fill'),
      clickAction: () => {
        SongLike.likeSong(song.id, (icon, msg) => {
          SnackBarUtils.showMessage([], icon, msg)
        })
      },
      customFontColor: [!this.isSongLiked(song) ? Color.White : Color.Red],
      customBgColor: Color.Transparent
    })
  }

  @Builder PlayListItemContextMenu(song: PlayListSong) {
    Column() {
      ArcCommonListItem({
        icon: $r('sys.symbol.list_interrupt'),
        title: $r('app.string.add_next_play'),
        customBgColor: Color.Transparent
      })
        .onClick(() => {
          PlayQueueUtils.queueAdd(PLAYMODE.SINGLE, SongConvertUtils.PlaylistSong2NormalSong(song), SongConvertUtils.getArtists(song.ar), '', song.al.picUrl)
        })
    }.borderRadius(12)
  }

  @Builder TopArea() {
    ArcListItem() {
      Column({space: 12}) {
        WearableImageCover({
          nowPlayingCoverImg: this.playListInfo.coverImgUrl
        })
        
        Text(this.playListInfo.name)
          .fontWeight(FontWeight.Bold).fontSize(16).fontColor(Color.White)
          .textAlign(TextAlign.Center).maxLines(2)
        
        ActionIconTextButton({
          clickAction: () => {
            this.playFullList()
          },
          icon: $r('sys.symbol.play_fill'),
          title: $r('app.string.common_play_button_play_num', this.playListInfo.trackCount)
        })
      }.padding(12)
    }.width(ArcConst.ARC_LIST_W)
  }

  build() {
    NavDestination() {
      ArcList() {
        this.TopArea()

        LazyForEach(this.fullPlayListDataSource, (song: WearablePlaylistSongViewModel, index) => {
          ArcListItem() {
            WearableInListSongItem({
              songName: song.s.name,
              coverInfo: song.s.al.picUrl,
              songArtist: SongConvertUtils.getArtists(song.s.ar),
              onPlay: () => {
                this.playFullList(index)
              },
              trailing: () => {
                this.PlayListItemTrailing(song.s)
              },
              isPlaying: song.s.id === this.nps.currentSong.id
            })
            .bindContextMenu(song.showMenu!!, this.PlayListItemContextMenu(song.s), {
              backgroundBlurStyle: BlurStyle.BACKGROUND_THICK,
              hapticFeedbackMode: HapticFeedbackMode.AUTO
            })
            .gesture(LongPressGesture().onAction(() => {
              song.showMenu = true
            }))
          }.width(ArcConst.ARC_LIST_W)
          .visibility(this.isLoading ? Visibility.Hidden : Visibility.Visible)
          .transition(TransitionEffect.OPACITY.animation({duration: 300}))
        }, (item: WearablePlaylistSongViewModel, index) => item.s.name + index)
      }
      .space(ArcConst.ARC_LIST_SPC)
      .fadingEdge(true)
      .height('100%')
    }
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .onReady((context) => {
      const params = context.pathInfo.param as Record<string, Object>
      if (params) {
        this.playListInfo = params['playListInfo'] as PlayList
      }
      this.onStart()
    })
    .onAppear(() => {
      EmitterUtil.onSubscribe(SCEmitter.PlaylistContentUpdate, (data: PlaylistContentUpdateInfo) => {
        this.onReceivePlayListSongUpdate(data)
      })
    })
    .onDisAppear(() => {
      EmitterUtil.unSubscribe(SCEmitter.PlaylistContentUpdate)
    })
    .opacity(this.pageOpacity)
    .animation({duration: 300})
  }

  onReceivePlayListSongUpdate(data: PlaylistContentUpdateInfo) {
    if (data.pid === this.playListInfo.id) {
      if (data.operation === 'add' || data.operation == undefined) {
        this.fullPlayListDetail.unshift(data.songInfo)
        this.fullPlayListDataSource.insertData(new WearablePlaylistSongViewModel(data.songInfo))
        this.fullPlayListDataSource.notifyDataReload()
        this.playListInfo.playCount = this.fullPlayListDetail.length
      } else {
        const index = this.fullPlayListDetail.findIndex((val) => val.id === data.songId)
        if (index !== -1) {
          this.fullPlayListDetail.splice(index, 1)
          this.fullPlayListDataSource.setData(WearablePlaylistSongViewModel.fromPlaylistData(this.fullPlayListDetail))
          this.fullPlayListDataSource.notifyDataReload()
        }
      }
      this.updateThisPlaylistLength()
    }
  }
  
  updateThisPlaylistLength() {
    // const newInfo = JSON.parse(JSON.stringify(this.playListInfo)) as PlayList
    // newInfo.playCount = this.fullPlayListDetail.length
    // this.playListInfo = newInfo
    // this.writeToUserStore()
  }

  writeToUserStore() {
    // const newInfo = JSON.parse(JSON.stringify(this.playListInfo)) as PlayList
    // const userPlayList = UserStore.userPlaylists.findIndex((val) => val.id === this.playListInfo.id)
    // if (userPlayList !== -1) {
    //   UserStore.userPlaylists[userPlayList] = newInfo
    //   UserManager.persistUserPlaylists()
    // }
  }

  async loadSongs(limit: number, offset: number): Promise<void> {
    if (!this.hasMore) return
    if (offset == 0) {
      this.isLoading = true
    }
    try {
      const result = await PlayListAPIUtils.getPlayListSongs(this.playListInfo.id, limit <= 1000 ? limit : 1000, offset, false)
      Logger.debug(TAG, `got result return: ${result.length}`)
      if (this.isLoading) {
        this.fullPlayListDetail = (result)
      } else {
        this.fullPlayListDetail.push(...result)
      }
      this.fullPlayListDataSource.setData(
        WearablePlaylistSongViewModel.fromPlaylistData(this.fullPlayListDetail)
      )
      this.fullPlayListDataSource.notifyDataReload()
      this.currentOffset += limit <= 1000 ? limit : 1000
      if (this.fullPlayListDetail.length >= this.playListInfo.trackCount) {
        this.hasMore = false
        SongAPIUtils.getLikeList(UserStore.user, (val) => {
          if (val) UserStore.likeList = new Set(val)
          UserManager.persistLikeList()
        })
      }
      limit -= 1000
      if(limit > 0) {
        this.loadSongs(limit, this.currentOffset)
      }
    } catch (e) {
      Logger.error(TAG, `ERR fetching songs: ${e}`)
    } finally {
      this.isLoading = false
    }
  }

  async playFullList(songIndex?: number) {
    if (songIndex !== undefined) {
      if (this.fullPlayListDetail[songIndex].id === NowPlayingStore.currentSong.id) {
        return;
      }
    }
    try {
      const playName = (songIndex !== undefined ? this.fullPlayListDetail[songIndex].name : this.playListInfo.name)
      SnackBarUtils.showMessage([], $r('sys.symbol.music_note_list'), $r('app.string.start_playing_le_NAME_ge_', playName))
      const queue = PlayQueueUtils.makeQueueByPlaylist(this.fullPlayListDetail)
      await PlayQueueUtils.cleanQueue()
      await PlayQueueUtils.queueAddArray(queue)
      await PlayControl.playQueue(songIndex ?? 0)
      NowPlayingStore.nowPlayingSource = PlaySourceData.DISABLED
    } catch (e) {
      Logger.error(TAG, `play full list failed: ${JSON.stringify(e)}`)
      SnackBarUtils.showMessage([], $r('sys.symbol.music_note_list'), $r('app.string.start_playing_list_failed'))
    }
  }

  removeSongFromPlaylist(song: PlayListSong) {
    const index = this.fullPlayListDetail.indexOf(song)
    PlayListAPIUtils.PlayListOperation("del", this.playListInfo.id, song.id)
      .then((res) => {
        if (res) {
          SnackBarUtils.showMessage([], $r('sys.symbol.trash'), $r('app.string.remove_song_success'))
          this.fullPlayListDetail.splice(index, 1)
          this.fullPlayListDataSource.deleteData(index)
          this.fullPlayListDataSource.notifyDataReload()
          this.updateThisPlaylistLength()
        } else {
          SnackBarUtils.showMessage([], $r('sys.symbol.trash'), $r('app.string.remove_song_failed'))
        }
      })
      .catch(() => {
        SnackBarUtils.showMessage([], $r('sys.symbol.trash'), $r('app.string.remove_song_failed'))
      })
  }

  addSongToList(song: PlayListSong) {
    GlobalContext.getContext().setObject(SCGlobal.addToPlaylistSongData, SongConvertUtils.PlaylistSong2NormalSong(song))
    this.showAddToPlaylistSheet = true
  }
}

export function generatePageParams_WearablePlayListDetail(playList: PlayList) {
  const params: Record<string, Object> = {}
  params['playListInfo'] = playList
  return params
}
