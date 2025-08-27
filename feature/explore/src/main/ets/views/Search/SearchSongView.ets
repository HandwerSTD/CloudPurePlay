import { Song, SongAPIUtils } from "@handwer/api_adapter"
import {
  GlobalStore,
  Logger,
  NowPlayingStore,
  PlayControl,
  PlayQueueUtils,
  ResponsiveUtil,
  SCApp,
  SongConvertUtils,
  SpecialPlayMode } from "@handwer/base"
import {
  InListSongItem,
  LightUpContainer,
  LightUpDefaultConfig,
  SnackBarUtils } from "@handwer/ui_components"
import { hdsEffect } from "@kit.UIDesignKit"
import { LazyData } from "@pie/lazy-data"
import { LengthMetrics } from "@kit.ArkUI"

const TAG = '[SearchSongView]'

@ComponentV2
export struct SearchSongView {
  @Consumer(SCApp.explorePageStack) pageStack: NavPathStack = new NavPathStack()
  @Param @Require searchContent: string
  @Local searchSongs: Song[] = []
  @Local searchSongsDataSource: LazyData<Song> = new LazyData()
  @Local fullWindowSizeArea?: Area
  @Local pageOpacity: number = 1
  @Local gridCount: number = ResponsiveUtil.chooseByWidth([1,2,3])
  @Local shouldLightSourceOff: boolean = false
  allSongs: Song[] = []

  shouldThisSongLightedUp(index: number): boolean {
    const checkId = (index: number) => {
      return this.searchSongs[index]?.id === NowPlayingStore.currentSong.id
    }
    const checkSm = () => {
      return checkId(index)
        || checkId(Math.min(index + 1, this.searchSongs.length-1))
        || checkId(Math.max(index - 1, 0))
    }
    const checkMd = () => {
      const len = this.searchSongs.length-1
      const far = (index % 2 == 0 ? checkId(Math.min(index + 3, len)) : checkId(Math.max(index - 3, 0)))
      return checkId(index)
      || checkId(Math.max(index - 1, 0))
      || checkId(Math.max(index - 2, 0))
      || checkId(Math.min(index + 1, len))
      || checkId(Math.min(index + 2, len))
      || far;
    }
    const checkLg = () => {
      const len = this.searchSongs.length - 1
      return checkId(index)
        // 左右一排
        || checkId(Math.max(index - 1, 0))
        || checkId(Math.max(index - 2, 0))
        || checkId(Math.max(index - 3, 0))
        || checkId(Math.min(index + 1, len))
        || checkId(Math.min(index + 2, len))
        || checkId(Math.min(index + 3, len))
        // 上下排
        || checkId(Math.max(index - 3, 0))
        || checkId(Math.max(index - 6, 0))
        || checkId(Math.min(index + 3, len))
        || checkId(Math.min(index + 6, len))
    }
    return ResponsiveUtil.chooseByWidth<() => boolean>([checkSm, checkMd, checkLg])();
  }

  @Builder Song_SingleItem(song: Song, index: number) {
    Stack({alignContent: Alignment.Center }) {
      // 点光源
      Row() {
        ForEach(([1, 2, 3, 4, 5]), () => {
          Column() {
          }.height(1).width(1)
          .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
            options: {
              height: song.id === NowPlayingStore.currentSong.id && !this.shouldLightSourceOff ? 100 : 0,
              intensity: 1
            }
          }).buildEffect())
          .animation({duration: 300})
        })
      }.justifyContent(FlexAlign.SpaceBetween).width('100%')

      // Song Item
      Column() {
        LightUpContainer({
          lightUpConfig: {
            lightIntensity: 1,
            lightHeight: 240,
          },
        }) {
          InListSongItem({
            songName: song.name,
            coverInfo: song.album.picUrl,
            songArtist: SongConvertUtils.getArtists(song.artists),
            onPlay: () => {
              this.playSingle(song)
            }
          })
        }
      }.padding({left: 12, right: 12})
      .backgroundColor(song.id === NowPlayingStore.currentSong.id ? $r('app.color.play_list_single_item_bg') : undefined)
      .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
        illuminatedType: this.shouldThisSongLightedUp(index) ? hdsEffect.PointLightIlluminatedType.BORDER : hdsEffect.PointLightIlluminatedType.NONE,
      }).buildEffect()).padding(ResponsiveUtil.chooseByWidth([6,12,12]))
      .borderRadius(20)
    }
  }

  @Builder TitleHeader() {
    Row() {
      Row({space: 12}) {
        SymbolGlyph($r('sys.symbol.play_circle_badge_music_note'))
          .fontColor([Color.White])
          .fontWeight(FontWeight.Bold )
          .fontSize(24)
          .padding(8)
          .backgroundColor($r('app.color.play_list_single_item_bg'))
          .borderRadius(10)
        Text($r('app.string.music_single'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        if (this.searchSongs.length > 0) {
          Divider().vertical(true).color(Color.White).width(1).height(24)
          Text($r('app.string.num_results', this.searchSongs.length))
            .fontSize(15)
            .fontColor(Color.White)
        }
      }
    }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    .padding(24)
  }

  @Builder MySongList() {
    ListItemGroup({space: 24}) {
      LazyForEach(this.searchSongsDataSource, (song: Song, index) => {
        ListItem() {
          this.Song_SingleItem(song, index)
        }
      }, (val: Song, index) => `${val.id}_${val.name}_${val.duration}_${index}`)
    }
    .transition(TransitionEffect.OPACITY
      .combine(TransitionEffect.translate({ y: 24 }))
      .animation({ duration: 500, curve: Curve.Friction}))
  }

  aboutToAppear(): void {
    SongAPIUtils.getAllSongs()
      .then((res) => {
        this.allSongs = res
        this.search()
      })
  }


  build() {
    NavDestination() {
      Column() {
        if (this.searchSongs.length > 0) {
          this.TitleHeader()
          List() {
            this.MySongList()
            ForEach((new Array(1).fill(0)), (_: number) => {
              ListItem().height(12)
            })
          }.width('100%')
          .layoutWeight(1)
          .cachedCount(20)
          .lanes(this.gridCount, 24)
          .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
          .fadingEdge(true, {
            fadingEdgeLength: LengthMetrics.percent(10)
          })
          .clip(false)
          .onAreaChange((_, nw) => {
            this.gridCount = ResponsiveUtil.chooseByWidth([1,2,3])
          })
          .onScrollStart(() => {
            this.shouldLightSourceOff = true
          })
          .onScrollStop(() => {
            this.shouldLightSourceOff = false
          })
        } else {
          // 空状态占位符
          Column() {
            SymbolGlyph($r('sys.symbol.play_circle_badge_music_note'))
              .fontColor([$r('sys.color.font_on_tertiary')])
              .fontSize(48)
              .margin({bottom: 12})
            Text($r('app.string.common_empty_content'))
              .fontColor($r('sys.color.font_on_tertiary'))
              .fontSize(16)
          }
          .justifyContent(FlexAlign.Center)
          .layoutWeight(1)
          .offset({y: -48})
        }
      }.height('100%').width('100%')
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onShown(() => {
      this.pageOpacity = 1
    })
    .onWillHide(() => {
      this.pageOpacity = 0
    })
    .opacity(this.pageOpacity)
    .animation({duration: ResponsiveUtil.chooseByWidth([300, 200, 200])})
  }

  @Monitor('searchContent')
  async search() {
    if (this.searchContent === '') {
      this.searchSongs = []
    } else {
      // 首先从本地歌曲中搜索
      const localResults = this.allSongs.filter((val): boolean => {
        return val.name.toLowerCase().includes(this.searchContent.toLowerCase()) ||
        SongConvertUtils.getArtists(val.artists).toLowerCase().includes(this.searchContent.toLowerCase())
      }).slice(0, 50) // 限制结果数量

      // 尝试从API搜索更多歌曲
      try {
        const apiResults = await SongAPIUtils.searchSongs(this.searchContent, 0, 30)
        // 合并本地和API结果，避免重复
        const combined = [...localResults]
        apiResults.list.forEach(apiSong => {
          if (!localResults.find(local => local.id === apiSong.id)) {
            combined.push(apiSong)
          }
        })
        this.searchSongs = combined.slice(0, 50) // 最终限制结果数量
      } catch (e) {
        // API搜索失败时只使用本地结果
        Logger.warn(TAG, `API search failed: ${e}`)
        this.searchSongs = localResults
      }
    }
    this.searchSongsDataSource.setData(this.searchSongs)
    this.searchSongsDataSource.notifyDataReload()
  }

  async playSingle(song: Song) {
    if (song.id === NowPlayingStore.currentSong.id) {
      return;
    }
    try {
      const playName = song.name
      SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.play_circle_badge_music_note'),
        $r('app.string.start_playing_le_NAME_ge_', playName))
      await PlayQueueUtils.cleanQueue()
      await PlayQueueUtils.queueAdd(1, song, '', '', song.album.picUrl) // SINGLE模式
      await PlayControl.playQueue(0)
      NowPlayingStore.specialPlayMode = SpecialPlayMode.DISABLED
    } catch (e) {
      Logger.error(TAG, `play single failed: ${JSON.stringify(e)}`)
      SnackBarUtils.showMessage(GlobalStore.globalSnack!, $r('sys.symbol.play_circle_badge_music_note'),
        $r('app.string.start_playing_failed'))
    }
  }
}