import {
  Album_INITIAL,
  PlayList, PlayListAPIUtils, PlayListSong, PlayList_INITIAL, SongAPIUtils } from "@handwer/api_adapter";
import { Logger, NowPlayingStore,
  PlayControl,
  PlayQueueUtils,
  ResponsiveUtil, SCApp, SongConvertUtils, SongLike,
  SpecialPlayMode,
  UserStore } from "@handwer/base";
import { HDS_TITLE_CONFIG_STYLE, ImageCover, InListSongItem,
  LightUpCommonButton,
  LightUpRoundedButton,
  SnackBarUtils } from "@handwer/ui_components";
import { hdsEffect, HdsNavDestination, HdsNavDestinationAttribute, HdsNavDestinationTitleMode,
  HdsSnackBar } from "@kit.UIDesignKit";
import { genId_MusicLibraryPlaylist } from "../components/MusicLibrary_MainPage";
import { curves } from "@kit.ArkUI";

const TAG = '[PlaylistDetail]'

@ComponentV2
export struct PlaylistDetail {
  snack = new HdsSnackBar(this.getUIContext())

  nps = NowPlayingStore
  @Local isLoading: boolean = false;
  hasMore: boolean = true;
  currentOffset: number = 0;;
  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()

  @Local playListInfo: PlayList = PlayList_INITIAL
  @Local fullPlayListDetail: PlayListSong[] = []

  @Local isListScrolling: boolean = false

  async onStart() {
    this.fullPlayListDetail = new Array(Math.min(100, this.playListInfo.trackCount)).fill({
      name: '', id: 0, al: Album_INITIAL, dt: 0, ar: [], fee: 0
    } as PlayListSong)
    await this.loadSongs(200, 0)
    await this.loadSongs(this.playListInfo.trackCount - 200, 200)
  }

  shouldThisSongLightedUp(index: number): boolean {
    const checkId = (index: number) => {
      return this.fullPlayListDetail[index].id === this.nps.currentSong.id
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
        icon: this.isSongLiked(song) ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'),
        clickAction: () => {
          SongLike.likeSong(song.id, (icon, msg) => {
            SnackBarUtils.showMessage(this.snack, icon, msg)
          })
        },
        customFontColor: [this.isSongLiked(song) ? Color.Red : Color.White],
        customBgColor: this.isSongLiked(song) ? Color.Transparent : undefined,
        lightUpConfig: {
          lightIntensity: 2,
          lightHeight: 150
        }
      })
    }.margin({left: 12, right: 12})
  }

  //--------------------------

  @Builder TopArea() {
    Column({space: 24}) {
      ImageCover({
        nowPlayingCoverImg: this.playListInfo.coverImgUrl
      })
        .width(ResponsiveUtil.chooseByWidth<Dimension>(['50%', '50%'])).aspectRatio(1)
      Text(this.playListInfo.name)
        .fontWeight(FontWeight.Bold).fontSize(24).fontColor(Color.White)
        .margin({left: 24, right: 24}).textAlign(TextAlign.Center)
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
          Text($r('app.string.common_play_button')).fontColor(Color.White)
        }
      }
    }.padding({top: 24, bottom: 24})
  }

  @Builder PlayList() {
    List({space: 12}) {
      ListItem().height(12)
      if (!ResponsiveUtil.widthCheck(['sm'])) {
        ListItem().height(12)
      }
      ForEach(this.fullPlayListDetail, (song: PlayListSong, index) => {
        ListItem() {
          Stack({alignContent: Alignment.Center }) {
            Row() {
              ForEach(([1, 2, 3, 4, 5]), () => {
                Column() {
                }.height(1).width(1)
                .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
                  options: {
                    height: song.id === this.nps.currentSong.id && !this.isListScrolling ? 100 : 0,
                    intensity: 1
                  }
                }).buildEffect())
                .animation({duration: 300})
              })
            }.justifyContent(FlexAlign.SpaceBetween).width('100%')

            Column() {
              InListSongItem({
                songName: song.name,
                songArtist: SongConvertUtils.getArtists(song.ar),
                onPlay: () => {
                  this.playFullList(index)
                },
                trailing: () => {
                  this.PlayListItemTrailing(song)
                }
              })
            }
            .backgroundColor(song.id === this.nps.currentSong.id ? $r('app.color.play_list_single_item_bg') : undefined)
            .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
              illuminatedType: this.shouldThisSongLightedUp(index) ? hdsEffect.PointLightIlluminatedType.BORDER : hdsEffect.PointLightIlluminatedType.NONE,
            }).buildEffect()).padding(ResponsiveUtil.chooseByWidth([6,12,12]))
            .borderRadius(20)
          }
        }
      })
    }.lanes(ResponsiveUtil.chooseByWidth([1,2]), 12)
    .divider({
      strokeWidth:1,
      startMargin: 12,
      endMargin: 12
    }).padding({left: ResponsiveUtil.chooseByWidth([6,12,12]), right: ResponsiveUtil.chooseByWidth([6,12,12])})
    .visibility(this.isLoading ? Visibility.Hidden : Visibility.Visible)
    .transition(TransitionEffect.OPACITY.animation({duration: 300}))
    // .animation({duration: 300})
  }

  build() {
    HdsNavDestination() {
      Column() {
        Scroll() {
          Flex({direction: ResponsiveUtil.wLgXl() ? FlexDirection.Row : FlexDirection.Column,
            alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start}) {
            this.TopArea()
            if (ResponsiveUtil.wLgXl()) {
              Divider().vertical(true)
                .padding(24)
            }
            this.PlayList()
          }.layoutWeight(1)
        }.edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true}).padding({left: 12, right: 12})
        .width('100%').height('100%')
        .onScrollStart(() => {
          this.isListScrolling = true
        })
        .onScrollStop(() => {
          this.isListScrolling = false
        })
      }.height('100%').width('100%')
    }.onReady((context) => {
      this.playListInfo = (context.pathInfo.param as Record<string, Object>)['playListInfo'] as PlayList
      this.onStart()
    })
    .titleBar({
      style: HDS_TITLE_CONFIG_STYLE
    })
    .visualEffect(new hdsEffect.HdsEffectBuilder().shaderEffect({
      effectType: hdsEffect.EffectType.UV_BACKGROUND_FLOW_LIGHT,
      animation: {
        duration: 5000,
        iterations: -1
      }
    }).buildEffect())
    // .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
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
      this.currentOffset += limit <= 1000 ? limit : 1000
      if (this.fullPlayListDetail.length >= this.playListInfo.trackCount) {
        this.hasMore = false
      }
      limit -= 1000
      if(limit > 0) {
        this.loadSongs(limit, this.currentOffset)
      }
    } catch (e) {
      // LogUtil.error(TAG, 'Error fetching songs: ', e.message)
      Logger.error(TAG, `ERR fetching songs: ${JSON.stringify(e)}`)
    } finally {
      // this.getUIContext().animateTo({curve: curves.springMotion()}, () => {
        this.isLoading = false
      // })
    }
  }

  async playFullList(songIndex?: number) {
    try {
      const playName = (songIndex ? this.fullPlayListDetail[songIndex].name : this.playListInfo.name)
      SnackBarUtils.showMessage(this.snack, $r('sys.symbol.music_note_list'), $r('app.string.start_playing_le_NAME_ge_', playName))
      const queue = PlayQueueUtils.makeQueueByPlaylist(this.fullPlayListDetail)
      await PlayQueueUtils.cleanQueue()
      await PlayQueueUtils.queueAddArray(queue)
      await PlayControl.playQueue(songIndex ?? 0)
      NowPlayingStore.specialPlayMode = SpecialPlayMode.DISABLED
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