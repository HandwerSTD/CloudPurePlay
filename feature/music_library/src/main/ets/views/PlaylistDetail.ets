import { PlayList, PlayListAPIUtils, PlayListSong, PlayList_INITIAL, SongAPIUtils } from "@handwer/api_adapter";
import { Logger, ResponsiveUtil, SCApp } from "@handwer/base";
import { ImageCover } from "@handwer/ui_components";
import { hdsEffect, HdsNavDestination, HdsNavDestinationAttribute, HdsNavDestinationTitleMode } from "@kit.UIDesignKit";
import { genId_MusicLibraryPlaylist } from "../components/MusicLibrary_MainPage";

const TAG = '[PlaylistDetail]'

@ComponentV2
export struct PlaylistDetail {
  isLoading: boolean = false;
  hasMore: boolean = true;
  currentOffset: number = 0;;
  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()

  @Local playListInfo: PlayList = PlayList_INITIAL
  @Local fullPlayListDetail: PlayListSong[] = []

  async onStart() {
    await this.loadSongs(200, 0)
    await this.loadSongs(this.playListInfo.trackCount - 200, 200)
  }

  @Builder TopArea() {
    Column({space: 24}) {
      ImageCover({
        nowPlayingCoverImg: this.playListInfo.coverImgUrl
      })
        .width(ResponsiveUtil.chooseByWidth<Dimension>(['100%', '50%'])).aspectRatio(1)
      Text(this.playListInfo.name)
        .fontWeight(FontWeight.Bold).fontSize(24)
    }
  }

  @Builder PlayList() {
    List() {
      ForEach(this.fullPlayListDetail, (song: PlayListSong) => {
        ListItem() {
          Row() {
            Text(song.name)
          }
        }
      })
    }
  }

  build() {
    HdsNavDestination() {
      Column() {
        this.TopArea()
        this.PlayList()
      }.height('100%').padding(12)
    }.onReady((context) => {
      this.playListInfo = (context.pathInfo.param as Record<string, Object>)['playListInfo'] as PlayList
      this.onStart()
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
      this.fullPlayListDetail.push(...result) // 合并歌曲列表
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
      this.isLoading = false
    }
  }
}

export function generatePageParams_PlayListDetail(playList: PlayList) {
  const params: Record<string, Object> = {}
  params['playListInfo'] = playList
  return params
}