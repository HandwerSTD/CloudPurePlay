import { GlobalStore, Logger, LyricUtils, NowPlayingStore, RetryUtil } from "@handwer/base"
import { Lyric, LyricStyle } from "@handwer/api_adapter"

const TAG = '[WearableLyricArea]'

@ComponentV2
export struct WearableLyricComponent {
  @Param miniMode: boolean = false

  nps = NowPlayingStore
  glb = GlobalStore

  @Local firstLoad: boolean = true
  @Local lyric: Lyric[] = []
  @Local isLoading: boolean = false
  @Local needUpdate: boolean = false

  private scroller: Scroller = new Scroller()

  @Monitor('glb.isInForeground')
  async onForegroundState() {
    if(this.glb.isInForeground === true && this.needUpdate) {
      await this.refreshLyric()
      this.needUpdate = false
      this.ToCurrentLyric()
    }
  }

  async aboutToAppear(): Promise<void> {
    RetryUtil.retry(2, async () => {
      await this.getLyric()
    }, async () => {
      return this.lyric.length > 0;
    }, 500)
    setTimeout(() => {
      this.scroller.scrollToIndex(NowPlayingStore.currentLyricIndex + 1, false, ScrollAlign.CENTER)
    }, 10)
  }

  async refreshLyric() {
    Logger.debug(TAG, `lyric loading`)
    this.needUpdate = true
    this.isLoading = true
    await this.getLyric()
    Logger.debug(TAG, `lyric get complete`)
    setTimeout(() => {
      this.isLoading = false
      Logger.debug(TAG, `lyric load completed`)
      this.ToCurrentLyric()
    }, 100)
  }

  async getLyric() {
    this.lyric = await LyricUtils.getLyricObjects()
  }

  @Monitor('nps.currentLyricIndex')
  ToCurrentLyric() {
    if(!this.isLoading) {
      this.scroller.scrollToIndex(this.nps.currentLyricIndex + 1, true, ScrollAlign.CENTER)
    }
  }

  build() {
    List({ scroller: this.scroller }) {
      if(!this.isLoading) {
        ListItem().height('30%') // 手表上使用更小的间距
        
        ForEach(this.lyric, (item: Lyric, index) => {
          WearableLyricLine({
            miniMode: this.miniMode,
            lyricStyle: this.nps.lyricStyle,
            currentLyricIndex: this.nps.currentLyricIndex,
            lyricData: item,
            index: index
          })
        })
        
        ListItem().height('30%')
      } else {
        // 加载状态
        ListItem() {
          Column() {
            Text($r('sys.string.cloud_file_download_loading'))
              .fontSize(12) // 手表上使用更小字体
              .fontColor(Color.White)
              .opacity(0.6)
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off) // 手表上隐藏滚动条
    .edgeEffect(EdgeEffect.None)
  }
}

@ComponentV2
struct WearableLyricLine {
  @Param @Require lyricStyle: LyricStyle
  @Param @Require currentLyricIndex: number
  @Param @Require lyricData: Lyric
  @Param @Require index: number
  @Param miniMode: boolean = false

  get isCurrentLine(): boolean {
    return this.index === this.currentLyricIndex
  }

  get fontSize(): number {
    if (this.miniMode) {
      return this.isCurrentLine ? 12 : 10 // 迷你模式更小字体
    }
    return this.isCurrentLine ? 14 : 12 // 手表正常模式字体
  }

  get fontColor(): ResourceColor {
    if (this.isCurrentLine) {
      return Color.White
    }
    return this.lyricStyle.color ? this.lyricStyle.color : Color.White
  }

  get _opacity(): number {
    return this.isCurrentLine ? 1.0 : 0.6
  }

  build() {
    ListItem() {
      Text(this.lyricData.content)
        .fontSize(this.fontSize)
        .fontColor(this.fontColor)
        .opacity(this._opacity)
        .textAlign(TextAlign.Center)
        .fontWeight(this.isCurrentLine ? FontWeight.Bold : FontWeight.Normal)
        .maxLines(2) // 手表上最多显示2行
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('90%')
        .animation({
          duration: 300,
          curve: Curve.Ease
        })
    }
    .width('100%')
    .padding({ top: 4, bottom: 4 }) // 手表上使用更小的行间距
    // .justifyContent(FlexAlign.Center)
  }
}
