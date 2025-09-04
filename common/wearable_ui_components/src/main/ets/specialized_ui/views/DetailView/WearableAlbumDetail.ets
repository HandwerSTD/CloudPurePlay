import {
  Album,
  AlbumAPIUtils,
  Album_INITIAL, PlayListSong, PLAYMODE } from "@handwer/api_adapter";
import {
  GlobalContext,
  Logger,
  NowPlayingStore,
  PlayControl,
  PlayQueueUtils,
  SCApp,
  SCGlobal,
  SongConvertUtils, SongLike,
  SpecialPlayMode,
  UserStore } from "@handwer/base";
import { HdsSnackBar } from "@kit.UIDesignKit";
import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute } from "@kit.ArkUI";
import { WearablePlaylistSongViewModel } from "./WearablePlaylistDetailViewmodel";
import { ActionButton, ActionIconTextButton } from "../../../components/ActionButton";
import { ArcCommonListItem } from "../../../components/CommonListItem";
import { ArcConst } from "../../../constants/WearableConstants";
import { SnackBarUtils } from "../../../utils/export";
import { WearableImageCover, WearableInListSongItem } from "../../exports";

const TAG = '[WearableAlbumDetail]'

export interface WearableAlbum_PopReturn {
  removed?: boolean
}

@ComponentV2
export struct WearableAlbumDetail {
  @Local pageOpacity: number = 1;
  snack = new HdsSnackBar(this.getUIContext())

  nps = NowPlayingStore
  @Local isLoading: boolean = false;
  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()
  @Consumer(SCApp.showAddToPlaylistSheet) showAddToPlaylistSheet: boolean = false

  @Local albumInfo: Album = Album_INITIAL
  @Local fullPlayListDetail: WearablePlaylistSongViewModel[] = []
  @Local showPlaylistOperationSheet: boolean = false
  @Local isThisAlbumSub: boolean = false

  async onStart() {
    this.fullPlayListDetail = new Array(Math.min(this.albumInfo.size)).fill(new WearablePlaylistSongViewModel({
      name: '', id: "0", al: Album_INITIAL, dt: 0, ar: [], fee: 0
    }))
    AlbumAPIUtils.getAlbumInfo(this.albumInfo.id)
      .then((res) => {
        this.fullPlayListDetail = WearablePlaylistSongViewModel.fromPlaylistData(res.songs)
      })
    this.isThisAlbumSub = UserStore.userSubAlbum.find((val) => val.id === this.albumInfo.id) !== undefined
  }

  isSongLiked(song: PlayListSong): boolean {
    return SongLike.isSongLiked(song.id)
  }

  @Builder PlayListItemTrailing(song: PlayListSong) {
    ActionButton({
      icon: !this.isSongLiked(song) ?  $r('sys.symbol.heart') : $r('sys.symbol.heart_fill'),
      clickAction: () => {
        SongLike.likeSong(song.id, (icon, msg) => {
          SnackBarUtils.showMessage(this.snack, icon, msg)
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
        title: $r('app.string.add_next_play')
      })
        .onClick(() => {
          PlayQueueUtils.queueAdd(PLAYMODE.SINGLE, SongConvertUtils.PlaylistSong2NormalSong(song), SongConvertUtils.getArtists(song.ar), '', song.al.picUrl)
        })
      
      ArcCommonListItem({
        icon: $r('sys.symbol.add_songlist'),
        title: $r('app.string.add_song_to_list')
      })
        .onClick(() => {
          this.addSongToList(song)
        })
    }.padding(8).borderRadius(12)
  }

  @Builder TopArea() {
    ArcListItem() {
      Column({space: 12}) {
        WearableImageCover({
          nowPlayingCoverImg: this.albumInfo.picUrl
        })
          .width('60%').aspectRatio(1)
        
        Text(this.albumInfo.name)
          .fontWeight(FontWeight.Bold).fontSize(16).fontColor(Color.White)
          .textAlign(TextAlign.Center).maxLines(2)
        
        ActionIconTextButton({
          clickAction: () => {
            this.playFullList()
          },
          icon: $r('sys.symbol.play_fill'),
          title: $r('app.string.common_play_button_play_num', this.albumInfo.size)
        })
      }.padding(12)
    }.width(ArcConst.ARC_LIST_W)
  }

  build() {
    Column() {
      ArcList() {
        this.TopArea()

        ForEach(this.fullPlayListDetail, (song: WearablePlaylistSongViewModel, index) => {
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
    .justifyContent(FlexAlign.Start)
    .onAppear(() => {
      // Initialize with parameter from navigation
      this.onStart()
    })
    .opacity(this.pageOpacity)
    .animation({duration: 300})
  }

  async playFullList(songIndex?: number) {
    if (songIndex !== undefined) {
      if (this.fullPlayListDetail[songIndex].s.id === NowPlayingStore.currentSong.id) {
        return;
      }
    }
    try {
      const playName = (songIndex !== undefined ? this.fullPlayListDetail[songIndex].s.name : this.albumInfo.name)
      SnackBarUtils.showMessage(this.snack, $r('sys.symbol.music_note_list'), $r('app.string.start_playing_le_NAME_ge_', playName))
      const queue = PlayQueueUtils.makeQueueByPlaylist(this.fullPlayListDetail.map((v) => v.s))
      await PlayQueueUtils.cleanQueue()
      await PlayQueueUtils.queueAddArray(queue)
      await PlayControl.playQueue(songIndex ?? 0)
      NowPlayingStore.specialPlayMode = SpecialPlayMode.DISABLED
    } catch (e) {
      Logger.error(TAG, `play full list failed: ${JSON.stringify(e)}`)
      SnackBarUtils.showMessage(this.snack, $r('sys.symbol.music_note_list'), $r('app.string.start_playing_list_failed'))
    }
  }

  addSongToList(song: PlayListSong) {
    GlobalContext.getContext().setObject(SCGlobal.addToPlaylistSongData, SongConvertUtils.PlaylistSong2NormalSong(song))
    this.showAddToPlaylistSheet = true
  }
}

export function generatePageParams_WearableAlbumDetail(album: Album) {
  const params: Record<string, Object> = {}
  params['albumInfo'] = album
  return params
}
