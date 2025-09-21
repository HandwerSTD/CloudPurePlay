import {
  Album_INITIAL,
  PlayList, PlayListAPIUtils, PlayListSong, PlayList_INITIAL,
  PLAYMODE,
  SongAPIUtils } from "@handwer/api_adapter";
import {
  GlobalContext,
  GlobalStore,
  Logger,
  NowPlayingStore,
  PlayControl,
  PlaylistContentUpdateInfo,
  PlayQueueUtils,
  ResponsiveUtil, SCApp,
  SCEmitter,
  SCGlobal,
  SongConvertUtils, SongLike,
  PlaySourceData,
  UserManager,
  UserStore,
  PlaySourceDataType} from "@handwer/base";
import { hdsEffect, HdsNavDestination, HdsNavDestinationAttribute, HdsNavigationAttribute,
  HdsNavigation,
  HdsNavigationTitleMode,
  HdsSnackBar } from "@kit.UIDesignKit";
import { LazyData } from "@pie/lazy-data";
import { LengthMetrics } from "@kit.ArkUI";
import { DialogHelper } from "@pura/harmony-dialog";
import { EmitterUtil } from "@pura/harmony-utils";
import { JSON } from "@kit.ArkTS";
import { HDS_TITLE_CONFIG_STYLE } from "../../../constants/HdsNavigationConfig";
import { LightUpRoundedButton, LightUpCommonButton } from "../../../light_up/LightUpButton";
import { LightUpLinedDefaultConfig } from "../../../light_up/LightUpConfig";
import { LightUpLinedContainer } from "../../../light_up/LightUpContainer";
import { DialogUtils } from "../../../utils/DialogUtils";
import { SnackBarUtils } from "../../../utils/SnackBarUtils";
import { CommonListItem, ImageCover, InListSongItem } from "../../exports";
import { PlaylistSongViewModel } from "./PlaylistDetailViewmodel";

const TAG = '[PlaylistDetail]'

export interface PlaylistDetail_PopReturn {
  removed?: boolean
}

@ComponentV2
export struct PlaylistDetail {
  @Local pageOpacity: number = 1;
  snack = new HdsSnackBar(this.getUIContext())

  nps = NowPlayingStore
  @Local isLoading: boolean = false;
  hasMore: boolean = true;
  currentOffset: number = 0;
  @Consumer(SCApp.exploreSheet) exploreSheet: boolean = false
  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()
  @Consumer(SCApp.showAddToPlaylistSheet) showAddToPlaylistSheet: boolean = false

  @Local playListInfo: PlayList = PlayList_INITIAL
  @Local fullPlayListDetail: PlayListSong[] = []
  @Local fullPlayListDataSource: LazyData<PlaylistSongViewModel> = new LazyData()
  @Local gridCount: number = 1
  @Local fullWindowSizeArea: Area | undefined = undefined

  @Local shouldLightSourceOff: boolean = false

  @Local showPlaylistOperationSheet: boolean = false

  get isThisHeartList() {
    return this.playListInfo.id === UserStore.userPlaylists[0]?.id ?? ''
  }

  async onStart() {
    // TODO: 性能优化
    this.fullPlayListDetail = new Array(Math.min(100, this.playListInfo.trackCount)).fill({
      name: '', id: "0", al: Album_INITIAL, dt: 0, ar: [], fee: 0
    } as PlayListSong)
    this.fullPlayListDataSource.setData(
      PlaylistSongViewModel.fromPlaylistData(this.fullPlayListDetail)
    )
    this.fullPlayListDataSource.notifyDataReload()
    const info = await PlayListAPIUtils.getPlaylistInfo(this.playListInfo.id)
    this.playListInfo = info
    this.writeToUserStore()
    await this.loadSongs(200, 0)
    await this.loadSongs(this.playListInfo.trackCount, 200)
  }

  shouldThisSongLightedUp(index: number): boolean {
    const checkId = (index: number) => {
      return this.fullPlayListDetail[index]?.id === this.nps.currentSong.id
    }
    const checkSm = () => {
      return checkId(index)
        || checkId(Math.min(index + 1, this.fullPlayListDetail.length-1))
        || checkId(Math.max(index - 1, 0))
    }
    const checkMd = () => {
      const len = this.fullPlayListDetail.length-1
      const far = (index % 2 == 0 ? checkId(Math.min(index + 3, len)) : checkId(Math.max(index - 3, 0)))
      return checkId(index)
      || checkId(Math.max(index - 1, 0))
      || checkId(Math.max(index - 2, 0))
      || checkId(Math.min(index + 1, len))
      || checkId(Math.min(index + 2, len))
      || far;
    }
    return ResponsiveUtil.chooseByWidth<() => boolean>([checkSm, checkMd])();
  }

  isSongLiked(song: PlayListSong): boolean {
    return SongLike.isSongLiked(song.id)
  }

  @Builder PlayListItemTrailing(song: PlayListSong) {
    Row() {
      LightUpRoundedButton({
        icon: !this.isSongLiked(song) ?  $r('sys.symbol.heart') : $r('sys.symbol.heart_fill'),
        clickAction: () => {
          SongLike.likeSong(song.id, (icon, msg) => {
            SnackBarUtils.showMessage(this.snack, icon, msg)
          })
        },
        customFontColor: [!this.isSongLiked(song) ? Color.White : Color.Red],
        customBgColor: Color.Transparent,
        lightUpConfig: {
          lightIntensity: 2,
          lightHeight: 150
        }
      })
    }.margin({left: 12, right: 12})
  }

  @Builder PlayListItemContextMenu(song: PlayListSong) {
    Column() {
      LightUpLinedContainer({lightUpConfig: LightUpLinedDefaultConfig}) {
        CommonListItem({
          icon: $r('sys.symbol.list_interrupt'),
          title: $r('app.string.add_next_play')
        })
          .onClick(() => {
            PlayQueueUtils.queueAdd(PLAYMODE.SINGLE, SongConvertUtils.PlaylistSong2NormalSong(song), SongConvertUtils.getArtists(song.ar), '', song.al.picUrl)
          })
      }
      LightUpLinedContainer({lightUpConfig: LightUpLinedDefaultConfig}) {
        CommonListItem({
          icon: $r('sys.symbol.add_songlist'),
          title: $r('app.string.add_song_to_list')
        })
          .onClick(() => {
            this.addSongToList(song)
          })
      }
      LightUpLinedContainer({lightUpConfig: LightUpLinedDefaultConfig}) {
        CommonListItem({
          icon: $r('sys.symbol.trash'),
          title: $r('app.string.remove_song_from_list')
        })
          .onClick(() => {
            this.removeSongFromPlaylist(song)
          })
      }
    }.borderRadius(24).margin(2)
    .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
      illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
    }).buildEffect())
  }

  @Builder TopAreaPlayButton_PlaylistOpSheet() {
    HdsNavigation() {
      List() {
        ListItem().height($r('sys.float.ohos_id_navigation_bar_height'))
          .margin({bottom: 12})
        ListItem() {
          Column() {
            if (!this.isThisHeartList) {
              LightUpLinedContainer({lightUpConfig: LightUpLinedDefaultConfig}) {
                CommonListItem({
                  icon: $r('sys.symbol.pencil_and_card'),
                  title: $r('app.string.common_rename')
                })
                  .onClick(() => {
                    this.renamePlaylist()
                  })
              }
            }
            LightUpLinedContainer({lightUpConfig: LightUpLinedDefaultConfig}) {
              CommonListItem({
                icon: $r('sys.symbol.list_interrupt'),
                title: $r('app.string.add_to_queue_end')
              })
                .onClick(() => {
                  this.addNextPlay()
                })
            }
            LightUpLinedContainer({lightUpConfig: LightUpLinedDefaultConfig}) {
              CommonListItem({
                icon: $r('sys.symbol.radiostation'),
                title: $r('app.string.add_to_personal_fm')
              })
                .onClick(() => {
                  this.addToPersonalFM()
                })
            }
            if (!this.isThisHeartList) {

              LightUpLinedContainer({lightUpConfig: LightUpLinedDefaultConfig}) {
                CommonListItem({
                  icon: $r('sys.symbol.trash'),
                  title: $r('app.string.remove_list')
                })
                  .onClick(() => {
                    this.onRemovePlaylist()
                  })
              }
            }
          }.borderRadius(24).margin({left: 12, right: 12})
          .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
            illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
          }).buildEffect())
        }
      }
    }.titleBar({
      style: HDS_TITLE_CONFIG_STYLE,
      content: {
        title: {
          mainTitle: $r('app.string.playlist_operations')
        }
      }
    }).titleMode(HdsNavigationTitleMode.MINI)
    .mode(NavigationMode.Stack)
  }

  @Builder TopAreaPlayButton() {
    Row({space: 12}) {
      LightUpCommonButton({
        clickAction: () => {
          this.playFullList()
        },
        lightUpConfig: { lightIntensity: 1, lightHeight: 240},
        customPadding: 16,
        useBorder: true
      }) {
        Row({space: 12}) {
          SymbolGlyph($r('sys.symbol.play_fill')).fontColor([Color.White]).fontWeight(FontWeight.Bold)
          Text($r('app.string.common_play_button_play_num', this.playListInfo.trackCount)).fontColor(Color.White)
        }
      }
      Row() {
        LightUpCommonButton({
          clickAction: () => {
            this.showPlaylistOperationSheet = !this.showPlaylistOperationSheet
          },
          lightUpConfig: { lightIntensity: 1, lightHeight: 240},
          customPadding: 16,
          useBorder: true
        }) {
          Row() {
            SymbolGlyph($r('sys.symbol.more')).fontColor([Color.White]).fontWeight(FontWeight.Bold)
          }.aspectRatio(1)
        }
      }
      .bindSheet(this.showPlaylistOperationSheet!!, this.TopAreaPlayButton_PlaylistOpSheet(), {
        backgroundColor: $r('app.color.ui_sheet_bg_col'),
        blurStyle: BlurStyle.BACKGROUND_THICK,
        preferType: SheetType.CENTER,
        showClose: false
      })
    }
  }

  //--------------------------

  @Builder TopArea() {
    Column({space: 24}) {
      ImageCover({
        nowPlayingCoverImg: this.playListInfo.coverImgUrl
      })
        .width(ResponsiveUtil.chooseByWidth<Dimension>(['50%', '50%'])).aspectRatio(1)
        .constraintSize(this. fullWindowSizeArea ? {
          maxWidth: (this.fullWindowSizeArea!.height.valueOf() as number) * 0.5
        } : undefined)
      Text(this.playListInfo.name)
        .fontWeight(FontWeight.Bold).fontSize(24).fontColor(Color.White)
        .margin({left: 24, right: 24}).textAlign(TextAlign.Center)
      this.TopAreaPlayButton()
    }.padding({top: 24, bottom: 24})
    .layoutWeight(ResponsiveUtil.wLgXl() ? 1 : undefined)
  }

  @Builder PlayList() {
    Grid() {
      // Paddings
      GridItem().columnStart(0).columnEnd(this.gridCount-1)
        .height(12)
      if (ResponsiveUtil.wLgXl()) {
        GridItem().columnStart(0).columnEnd(this.gridCount-1)
          .height($r('sys.float.ohos_id_navigation_bar_height'))
      } else {
        GridItem() {
          this.TopArea()
        }.columnStart(0).columnEnd(this.gridCount-1)
      }

      // Songs
        LazyForEach(this.fullPlayListDataSource, (song: PlaylistSongViewModel, index) => {
          GridItem() {
            Stack({alignContent: Alignment.Center }) {
              // 点光源
              Row() {
                ForEach(([1, 2, 3, 4, 5]), () => {
                  Column() {
                  }.height(1).width(1).opacity(0)
                  .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
                    illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT,
                    options: {
                      height: song.s.id === this.nps.currentSong.id && !this.shouldLightSourceOff ? 100 : 0,
                      intensity: 1
                    }
                  }).buildEffect())
                  .animation({duration: 300})
                })
              }.justifyContent(FlexAlign.SpaceBetween).width('100%')

              // Song Item
              Column() {
                Column() {
                  InListSongItem({
                    songName: song.s.name,
                    coverInfo: song.s.al.picUrl,
                    songArtist: SongConvertUtils.getArtists(song.s.ar),
                    onPlay: () => {
                      this.playFullList(index)
                    },
                    trailing: () => {
                      this.PlayListItemTrailing(song.s)
                    }
                  })
                }.padding({left: 12, right: 12})
                  .backgroundColor(song.s.id === this.nps.currentSong.id ? $r('app.color.play_list_single_item_bg') : undefined)
                  .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
                    illuminatedType: this.shouldThisSongLightedUp(index) ? hdsEffect.PointLightIlluminatedType.BORDER : hdsEffect.PointLightIlluminatedType.NONE,
                  }).buildEffect()).padding(ResponsiveUtil.chooseByWidth([6,12,12]))
                  .borderRadius(20)
                  .bindContextMenu(song.showMenu!!, this.PlayListItemContextMenu(song.s), {
                    backgroundBlurStyle: BlurStyle.BACKGROUND_THICK,
                    hapticFeedbackMode: HapticFeedbackMode.AUTO
                  })
                  .gesture(LongPressGesture().onAction(() => {
                    song.showMenu = true
                  }))
                  .onMouse((event) => {
                    if (event.button === MouseButton.Right) {
                      song.showMenu
                    }
                  })
              }
            }
          }
          .visibility(this.isLoading ? Visibility.Hidden : Visibility.Visible)
          .transition(TransitionEffect.OPACITY.animation({duration: 300}))
        }, (item: PlaylistSongViewModel, index) => item.s.name + index)
    }.columnsTemplate(this.gridCount === 1 ? '1fr' : '1fr 1fr')
    .columnsGap(12).rowsGap(12)
    .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true}).padding({left: 12, right: 12})
    .backToTop(true)
    .cachedCount(this.gridCount * 6)
    .fadingEdge(true, {
      fadingEdgeLength: LengthMetrics.percent(10)
    })
    .layoutWeight(ResponsiveUtil.wLgXl() ? 2 : undefined)
    .height('100%')
    .padding({
      left: ResponsiveUtil.chooseByWidth([12,12,12]),
      right: ResponsiveUtil.chooseByWidth([12,12,12])
    })
  }

  @Builder LandscapePage() {
    Flex({ direction: FlexDirection.Row,
      alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start}) {
      this.TopArea()
      if (ResponsiveUtil.wLgXl()) {
        Divider().vertical(true)
          .padding(24)
      }
      this.PlayList()
    }.layoutWeight(1)
  }

  @Builder PortraitPage() {
      this.PlayList()
  }

  build() {
    HdsNavDestination() {
      Column() {
        if (ResponsiveUtil.wLgXl()) {
          this.LandscapePage()
        } else {
          this.PortraitPage()
        }
      }.height('100%').width('100%')
    }.onReady((context) => {
      this.playListInfo = (context.pathInfo.param as Record<string, Object>)['playListInfo'] as PlayList
      this.onStart()
      EmitterUtil.onSubscribe(SCEmitter.PlaylistContentUpdate, (data: PlaylistContentUpdateInfo) => {
        this.onReceivePlayListSongUpdate(data)
      })
    })
    .onBackPressed(() => {
      if (!this.exploreSheet) {
        this.exploreSheet = true;
        return true;
      }
      this.pageStack.pop({} as PlaylistDetail_PopReturn, true)
      return true;
    })
    .onWillDisappear(() => {
      this.shouldLightSourceOff = true
      EmitterUtil.unSubscribe(SCEmitter.PlaylistContentUpdate)
    })
    .titleBar({
      style: HDS_TITLE_CONFIG_STYLE
    })
    .onAreaChange((_, nw) => {
      this.gridCount = ResponsiveUtil.chooseByWidth([1,2])
      this.fullWindowSizeArea = nw
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
    // .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
  }

  onReceivePlayListSongUpdate(data: PlaylistContentUpdateInfo) {
    if (data.pid === this.playListInfo.id) {
      if (data.operation === 'add' || data.operation == undefined) {
        // add song
        this.fullPlayListDetail.unshift(data.songInfo)
        this.fullPlayListDataSource.insertData(new PlaylistSongViewModel(data.songInfo))
        this.fullPlayListDataSource.notifyDataReload()
        this.playListInfo.playCount = this.fullPlayListDetail.length
      } else {
        // remove song
        const index = this.fullPlayListDetail.findIndex((val) => val.id === data.songId)
        if (index !== -1) {
          this.fullPlayListDetail.splice(index, 1)
          this.fullPlayListDataSource.setData(PlaylistSongViewModel.fromPlaylistData(this.fullPlayListDetail))
          this.fullPlayListDataSource.notifyDataReload()
        }
      }
      this.updateThisPlaylistLength()
    }
  }
  updateThisPlaylistLength() {
    const newInfo = JSON.parse(JSON.stringify(this.playListInfo)) as PlayList
    newInfo.playCount = this.fullPlayListDetail.length
    this.playListInfo = newInfo
    this.writeToUserStore()
  }
  writeToUserStore() {
    const newInfo = JSON.parse(JSON.stringify(this.playListInfo)) as PlayList
    const userPlayList = UserStore.userPlaylists.findIndex((val) => val.id === this.playListInfo.id)
    if (userPlayList !== -1) {
      UserStore.userPlaylists[userPlayList] = newInfo
      UserManager.persistUserPlaylists()
    }
  }

  async loadSongs(limit: number, offset: number): Promise<void> {
    if (!this.hasMore) return // 直接返回
    if (offset == 0) {
      this.isLoading = true // 初次加载
    }
    try {
      const result = await PlayListAPIUtils.getPlayListSongs(this.playListInfo.id, limit <= 1000 ? limit : 1000, offset, false)
      Logger.debug(TAG, `got result return: ${result.length}`)
      if (this.isLoading) {
        this.fullPlayListDetail = (result) // 合并歌曲列表
      } else {
        this.fullPlayListDetail.push(...result) // 合并歌曲列表
      }
      this.fullPlayListDataSource.setData(
        PlaylistSongViewModel.fromPlaylistData(this.fullPlayListDetail)
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
      // LogUtil.error(TAG, 'Error fetching songs: ', e.message)
      Logger.error(TAG, `ERR fetching songs: ${e.message} + ${e.stacktrace}`)
    } finally {
      // this.getUIContext().animateTo({curve: curves.springMotion()}, () => {
        this.isLoading = false
      // })
    }
  }

  async playFullList(songIndex?: number) {
    if (songIndex) {
      if (this.fullPlayListDetail[songIndex].id === NowPlayingStore.currentSong.id) {
        return;
      }
    }
    try {
      const playName = (songIndex ? this.fullPlayListDetail[songIndex].name : this.playListInfo.name)
      SnackBarUtils.showMessage(this.snack, $r('sys.symbol.music_note_list'), $r('app.string.start_playing_le_NAME_ge_', playName))
      const queue = PlayQueueUtils.makeQueueByPlaylist(this.fullPlayListDetail)
      await PlayQueueUtils.cleanQueue()
      await PlayQueueUtils.queueAddArray(queue)
      await PlayControl.playQueue(songIndex ?? 0)
      NowPlayingStore.nowPlayingSource = new PlaySourceData(PlaySourceDataType.PLAY_LIST, this.playListInfo.id)
    } catch (e) {
      Logger.error(TAG, `play full list failed: ${JSON.stringify(e)}`)
      SnackBarUtils.showMessage(this.snack, $r('sys.symbol.music_note_list'), $r('app.string.start_playing_list_failed'))
    }
  }


  onRemovePlaylist() {
    const play = this.playListInfo

    const remove = () => {
      const id = DialogHelper.showLoadingDialog()
      PlayListAPIUtils.deletePlayList(play.id)
        .then((res) => {
          if (res) {
            SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.trash'),
              $r('app.string.remove_list_success'));
            this.showPlaylistOperationSheet = false
            this.pageStack.pop({
              removed: true
            } as PlaylistDetail_PopReturn)
          } else {
            SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.trash'),
              $r('app.string.remove_list_failed'));
          }
        })
        .catch(() => {
          SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.trash'),
            $r('app.string.remove_list_failed'));
        })
        .finally(() => {
          DialogHelper.closeDialog(id)
        })
    }
    const unsub = () => {
      const id = DialogHelper.showLoadingDialog()
      PlayListAPIUtils.subscribePlayList(play.id, 2)
        .then((res) => {
          if (res) {
            SnackBarUtils.showMessage(this.snack, $r('sys.symbol.heart_square_stack'),
              $r('app.string.unsubscribe_success'));
            this.showPlaylistOperationSheet = false
            this.pageStack.pop({
              removed: true
            } as PlaylistDetail_PopReturn)
          } else {
            SnackBarUtils.showMessage(this.snack, $r('sys.symbol.heart_square_stack'),
              $r('app.string.unsubscribe_failed'));
          }
        })
        .catch(() => {
          SnackBarUtils.showMessage(this.snack, $r('sys.symbol.heart_square_stack'),
            $r('app.string.unsubscribe_failed'));
        })
        .finally(() => {
          DialogHelper.closeDialog(id)
        })
    }

    if (play.userId === UserStore.userId) {
      DialogUtils.showAlertDialog(
        this.getUIContext(),
        $r('app.string.remove_list'), $r('app.string.remove_list_alert_content'), () => {},
        () => {
          remove()
        })
    } else {
      DialogUtils.showAlertDialog(
        this.getUIContext(),
        $r('app.string.unsubscribe'), $r('app.string.unsubscribe_alert_content'), () => {},
        () => {
          unsub()
        })
    }
  }

  renamePlaylist() {
    DialogUtils.showTextInputDialog($r('app.string.common_rename'), this.playListInfo.name, (result) => {
      if (result === '' || result === this.playListInfo.name) return
      PlayListAPIUtils.renamePlaylist(this.playListInfo.id, result)
        .then((res) => {
          if (res) {
            // this page
            let np = JSON.parse(JSON.stringify(this.playListInfo)) as PlayList
            np.name = result
            this.playListInfo = np

            // global
            const p = UserStore.userPlaylists.findIndex((v) => v.id === this.playListInfo.id)
            if (p !== -1) {
              let np = JSON.parse(JSON.stringify(UserStore.userPlaylists[p])) as PlayList
              np.name = result
              UserStore.userPlaylists[p] = np
            }
          } else {
            SnackBarUtils.showMessage(this.snack, $r('sys.symbol.pencil_and_card'), $r('app.string.rename_failed'))
          }
        })
        .catch(() => {
          SnackBarUtils.showMessage(this.snack, $r('sys.symbol.pencil_and_card'), $r('app.string.rename_failed'))
        })
    })
  }

  removeSongFromPlaylist(song: PlayListSong) {
    const index = this.fullPlayListDetail.indexOf(song)
    PlayListAPIUtils.PlayListOperation("del", this.playListInfo.id, song.id)
      .then((res) => {
        if (res) {
          SnackBarUtils.showMessage(this.snack, $r('sys.symbol.trash'), $r('app.string.remove_song_success'))
          this.fullPlayListDetail.splice(index, 1)
          this.fullPlayListDataSource.deleteData(index)
          this.fullPlayListDataSource.notifyDataReload()
          this.updateThisPlaylistLength()
        } else {
          SnackBarUtils.showMessage(this.snack, $r('sys.symbol.trash'), $r('app.string.remove_song_failed'))
        }
      })
      .catch(() => {
        SnackBarUtils.showMessage(this.snack, $r('sys.symbol.trash'), $r('app.string.remove_song_failed'))
      })
  }

  addSongToList(song: PlayListSong) {
    GlobalContext.getContext().setObject(SCGlobal.addToPlaylistSongData, SongConvertUtils.PlaylistSong2NormalSong(song))
    this.showAddToPlaylistSheet = true
  }


  async addNextPlay() {
    try {
      const queue = PlayQueueUtils.makeQueueByPlaylist(this.fullPlayListDetail)
      await PlayQueueUtils.queueAddArray(queue)
      // NowPlayingStore.nowPlayingSource = PlaySourceData.DISABLED
      SnackBarUtils.showMessage(this.snack, $r('sys.symbol.music_note_list'), $r('app.string.add_next_play_success'))
    } catch (e) {
      Logger.error(TAG, `play full list failed: ${JSON.stringify(e)}`)
      SnackBarUtils.showMessage(this.snack, $r('sys.symbol.music_note_list'), $r('app.string.start_playing_list_failed'))
    }
  }
  async addToPersonalFM() {
    try {
      const queue = PlayQueueUtils.makeQueueByPlaylist(this.fullPlayListDetail)
      await PlayQueueUtils.cleanQueue()
      await PlayQueueUtils.queueAddArray(queue)
      await PlayControl.playQueue(0)
      NowPlayingStore.nowPlayingSource = PlaySourceData.PERSONAL_FM
      SnackBarUtils.showMessage(this.snack, $r('sys.symbol.music_note_list'), $r('app.string.add_to_personal_fm_success'))
    } catch (e) {
      Logger.error(TAG, `play full list failed: ${JSON.stringify(e)}`)
      SnackBarUtils.showMessage(this.snack, $r('sys.symbol.music_note_list'), $r('app.string.start_playing_list_failed'))
    }
  }
}

export function generatePageParams_PlayListDetail(playList: PlayList) {
  const params: Record<string, Object> = {}
  params['playListInfo'] = playList
  return params
}