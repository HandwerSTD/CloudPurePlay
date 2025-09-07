import {
  Album,
  AlbumAPIUtils,
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
import {
  CommonListItem,
  HDS_TITLE_CONFIG_STYLE, ImageCover, InListSongItem,
  LightUpCommonButton,
  LightUpLinedContainer,
  LightUpRoundedButton,
  LightUpLinedDefaultConfig,
  SnackBarUtils,
  DialogUtils} from "../../../../../../Index";
import { hdsEffect, HdsNavDestination, HdsNavDestinationAttribute, HdsNavigationAttribute,
  HdsNavigation,
  HdsNavigationTitleMode,
  HdsSnackBar } from "@kit.UIDesignKit";
import { LazyData } from "@pie/lazy-data";
import { LengthMetrics } from "@kit.ArkUI";
import { DialogHelper } from "@pura/harmony-dialog";
import { EmitterUtil } from "@pura/harmony-utils";
import { JSON } from "@kit.ArkTS";
import { PlaylistSongViewModel } from "./PlaylistDetailViewmodel";

const TAG = '[AlbumDetail]'

export interface Album_PopReturn {
  removed?: boolean
}

@ComponentV2
export struct AlbumDetail {
  @Local pageOpacity: number = 1;
  snack = new HdsSnackBar(this.getUIContext())

  nps = NowPlayingStore
  @Local isLoading: boolean = false;
  hasMore: boolean = true;
  currentOffset: number = 0;
  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()
  @Consumer(SCApp.showAddToPlaylistSheet) showAddToPlaylistSheet: boolean = false

  @Local albumInfo: Album = Album_INITIAL
  @Local fullPlayListDetail: PlaylistSongViewModel[] = []
  @Local gridCount: number = 1
  @Local fullWindowSizeArea: Area | undefined = undefined

  @Local shouldLightSourceOff: boolean = false

  @Local showPlaylistOperationSheet: boolean = false

  @Local isThisAlbumSub: boolean = false

  async onStart() {
    this.fullPlayListDetail = new Array(Math.min(this.albumInfo.size)).fill(new PlaylistSongViewModel({
      name: '', id: "0", al: Album_INITIAL, dt: 0, ar: [], fee: 0
    }))
    AlbumAPIUtils.getAlbumInfo(this.albumInfo.id)
      .then((res) => {
        this.fullPlayListDetail = PlaylistSongViewModel.fromPlaylistData(res.songs)
      })
    this.isThisAlbumSub = UserStore.userSubAlbum.find((val) => val.id === this.albumInfo.id) !== undefined
  }

  shouldThisSongLightedUp(index: number): boolean {
    const checkId = (index: number) => {
      return this.fullPlayListDetail[index]?.s.id === this.nps.currentSong.id
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
    return ResponsiveUtil.chooseByWidth<() => boolean>([checkSm, checkMd])()
      || index < 2; //播放按钮，让前两个也亮起来
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
            LightUpLinedContainer({lightUpConfig: LightUpLinedDefaultConfig}) {
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
              // LightUpLinedContainer({lightUpConfig: LightUpLinedDefaultConfig}) {
              //   CommonListItem({
              //     icon: $r('sys.symbol.info_circle'),
              //     title: $r('app.string.add_to_personal_fm')
              //   })
              //     .onClick(() => {
              //       this.showAlbumInfo()
              //     })
              // }
              if (this.isThisAlbumSub) {
                CommonListItem({
                  icon: $r('sys.symbol.trash'),
                  title: $r('app.string.unsubscribe')
                })
                  .onClick(() => {
                    this.onRemoveAlbum()
                  })
              } else {
                CommonListItem({
                  icon: $r('sys.symbol.opticaldisc_badge_diamond'),
                  title: $r('app.string.subscribe_album')
                })
                  .onClick(() => {
                    this.onSubscribeAlbum()
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
          mainTitle: $r('app.string.Album')
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
          Text($r('app.string.common_play_button_play_num', this.albumInfo.size)).fontColor(Color.White)
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
        nowPlayingCoverImg: this.albumInfo.picUrl
      })
        .width(ResponsiveUtil.chooseByWidth<Dimension>(['50%', '50%'])).aspectRatio(1)
        .constraintSize(this. fullWindowSizeArea ? {
          maxWidth: (this.fullWindowSizeArea!.height.valueOf() as number) * 0.5
        } : undefined)
      Text(this.albumInfo.name)
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
      ForEach(this.fullPlayListDetail, (song: PlaylistSongViewModel, index) => {
        GridItem() {
          Stack({alignContent: Alignment.Center }) {
            // 点光源
            Row() {
              ForEach(([1, 2, 3, 4, 5]), () => {
                Column() {
                }.height(1).width(1)
                .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
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
    .onScrollStart(() => {
      this.shouldLightSourceOff = true
    })
    .onScrollStop(() => {
      this.shouldLightSourceOff = false
    })
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
      this.albumInfo = (context.pathInfo.param as Record<string, Object>)['albumInfo'] as Album
      this.onStart()
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

  async playFullList(songIndex?: number) {
    if (songIndex) {
      if (this.fullPlayListDetail[songIndex].s.id === NowPlayingStore.currentSong.id) {
        return;
      }
    }
    try {
      const playName = (songIndex ? this.fullPlayListDetail[songIndex].s.name : this.albumInfo.name)
      SnackBarUtils.showMessage(this.snack, $r('sys.symbol.music_note_list'), $r('app.string.start_playing_le_NAME_ge_', playName))
      const queue = PlayQueueUtils.makeQueueByPlaylist(this.fullPlayListDetail.map((v) => v.s))
      await PlayQueueUtils.cleanQueue()
      await PlayQueueUtils.queueAddArray(queue)
      await PlayControl.playQueue(songIndex ?? 0)
      NowPlayingStore.nowPlayingSource = new PlaySourceData(PlaySourceDataType.ALBUM, this.albumInfo.id)
    } catch (e) {
      Logger.error(TAG, `play full list failed: ${JSON.stringify(e)}`)
      SnackBarUtils.showMessage(this.snack, $r('sys.symbol.music_note_list'), $r('app.string.start_playing_list_failed'))
    }
  }


  onSubscribeAlbum() {
    const play = this.albumInfo
    AlbumAPIUtils.subscribeAlbum(play.id, 0)
      .then((res) => {
        if (res) {
          SnackBarUtils.showMessage(this.snack, $r('sys.symbol.opticaldisc'),
            $r('app.string.subscribe_success'));
          this.showPlaylistOperationSheet = false
          UserManager.fetchUserSubAlbum()
          this.isThisAlbumSub = true
        } else {
          throw Error()
        }
      })
      .catch(() => {
        SnackBarUtils.showMessage(this.snack, $r('sys.symbol.opticaldisc'),
          $r('app.string.subscribe_failed'));
      })
  }
  onRemoveAlbum() {
    const play = this.albumInfo

    const unsub = () => {
      const id = DialogHelper.showLoadingDialog()
      AlbumAPIUtils.subscribeAlbum(play.id, 0)
        .then((res) => {
          if (res) {
            SnackBarUtils.showMessage(this.snack, $r('sys.symbol.heart_square_stack'),
              $r('app.string.unsubscribe_success'));
            this.showPlaylistOperationSheet = false
            this.pageStack.pop({
              removed: true
            } as Album_PopReturn)
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

    DialogUtils.showAlertDialog(
      this.getUIContext(),
      $r('app.string.unsubscribe'), $r('app.string.unsubscribe_alert_content'), () => {},
      () => {
        unsub()
      })
  }

  addSongToList(song: PlayListSong) {
    GlobalContext.getContext().setObject(SCGlobal.addToPlaylistSongData, SongConvertUtils.PlaylistSong2NormalSong(song))
    this.showAddToPlaylistSheet = true
  }


  async addNextPlay() {
    try {
      const queue = PlayQueueUtils.makeQueueByPlaylist(this.fullPlayListDetail.map((v) => v.s))
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
      const queue = PlayQueueUtils.makeQueueByPlaylist(this.fullPlayListDetail.map((v) => v.s))
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
  showAlbumInfo() {

  }
}

export function generatePageParams_AlbumDetail(album: Album) {
  const params: Record<string, Object> = {}
  params['albumInfo'] = album
  return params
}