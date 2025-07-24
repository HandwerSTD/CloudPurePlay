import { GlobalStore, Logger, LyricUtils, NowPlayingStore, PlayControl, SCEmitter } from "@handwer/base"
import { Lyric, LyricStyle, LyricStyle_INITIAL } from "@handwer/cloud_api"
import { LazyData } from "@pie/lazy-data"
import { LengthUnit } from "@kit.ArkUI"
import { EmitterUtil } from "@pura/harmony-utils"

const TAG = '[LyricArea]'

@ComponentV2
export struct LyricComponent {
  currentLyricIndex = NowPlayingStore.currentLyricIndex
  lyricStyle = NowPlayingStore.lyricStyle
  isInForeground = GlobalStore.isInForeground

  @Local firstLoad: boolean = true
  @Local userScrolling: number = 0
  @Local userScrollingInterval: number = 0
  @Local lyric: Lyric[] = []
  @Local isLoading: boolean = false
  @Local needUpdate: boolean = false
  @Local dataSource: LazyData<Lyric> = new LazyData()
  @Local newLyricEffect: boolean = true

  private scroller: Scroller = new Scroller()

  async onForegroundState() {
    if(this.isInForeground === true && this.needUpdate) {
      await this.refreshLyric()
      this.needUpdate = false
      this.ToCurrentLyric()
    }
  }

  async aboutToAppear(): Promise<void> {
    await this.refreshLyric()
    setTimeout(() => {
      this.scroller.scrollToIndex(NowPlayingStore.currentLyricIndex + 1, false, ScrollAlign.CENTER)
    }, 10)
    this.StartAutoScrollTimer()
  }

  async refreshLyric() {
    this.userScrolling = 0
    this.needUpdate = true
    this.isLoading = true
    await this.getLyric()
    setTimeout(() => {
      this.isLoading = false
      Logger.debug(TAG, `lyric load completed`)
      this.ToCurrentLyric()
    }, 100)
  }

  aboutToDisappear(): void {
    clearInterval(this.userScrollingInterval)
  }

  private StartAutoScrollTimer() {
    this.userScrollingInterval = setInterval(() => {
      if(this.userScrolling > 0) {
        this.userScrolling -= 1
      } else if(this.userScrolling === 0) {
        this.ToCurrentLyric()
      }
    }, 1000)
  }

  async getLyric() {
    this.lyric = await LyricUtils.getLyricObjects()
    this.dataSource.setData(this.lyric)
    this.dataSource.notifyDataReload()
  }

  ToCurrentLyric() {
    if(!this.userScrolling && !this.isLoading) {
      this.scroller.scrollToIndex(this.currentLyricIndex + 1, true, ScrollAlign.CENTER)
    }
  }

  build() {
    List({ scroller: this.scroller }) {
      if(!this.isLoading) {
        ListItem().height('50%')
        if(this.newLyricEffect) {
          LazyForEach(this.dataSource, (item: Lyric, index) => {
            LyricLine({
              lyricStyle: this.lyricStyle,
              currentLyricIndex: this.currentLyricIndex,
              userScrolling: this.userScrolling!!,
              index: index,
              item: item
            })
              .offset({ y: this.Offset(index) })
              .animation({
                delay: this.userScrolling ? 0 : this.Delay(index),
                duration: this.userScrolling ? 0 : 600,
                curve: Curve.Smooth,
                expectedFrameRateRange: {
                  expected: 90,
                  min: 60,
                  max: 90
                }
              })
              .padding({
                bottom: !this.userScrolling
                  ? (index >= this.currentLyricIndex ? this.lyricStyle.size : this.lyricStyle.size * 2)
                  : this.lyricStyle.size * 2
              })
              .animation({ duration: this.userScrolling ? 0 : 300, curve: Curve.Friction })
          })
        } else {
          LazyForEach(this.dataSource, (item: Lyric, index) => {
            LyricLine({
              lyricStyle: this.lyricStyle,
              currentLyricIndex: this.currentLyricIndex,
              userScrolling: this.userScrolling!!,
              index: index,
              item: item
            })
              .padding({ bottom: this.lyricStyle.size * 2 })
          })
        }
        ListItem().height('50%')
      }
    }
    .cachedCount(3)
    .alignListItem(ListItemAlign.End)
    .padding({ top: 30 })
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring)
    .listDirection(Axis.Vertical)
    .scrollBar(BarState.Off)
    .fadingEdge(true, {
      fadingEdgeLength: {
        unit: LengthUnit.PERCENT,
        value: 40
      }
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Move) {
        this.userScrolling = 2
      }
    })
    .onAppear(() => {
      EmitterUtil.onSubscribe(SCEmitter.LyricUpdate, this.refreshLyric)
    })
    .onDisAppear(() => {
      EmitterUtil.unSubscribe(SCEmitter.LyricUpdate)
    })
  }

  Offset(index: number) {
    if(this.userScrolling) return 0
    const LINE_SPACING = this.lyricStyle.size
    const delta = index - this.currentLyricIndex
    let offset = delta > 0 ? delta * LINE_SPACING : 0
    return offset
  }

  Delay(index: number) {
    if(this.userScrolling) return 0
    const delta = index - this.currentLyricIndex
    return Math.max(delta * 80, 0)
  }

}

@ComponentV2
struct LyricLine {
  @Param index: number = 0
  @Param item: Lyric = { time: 0, content: '' }
  @Param currentLyricIndex: number = 0
  @Param lyricStyle: LyricStyle = LyricStyle_INITIAL
  @Param @Require userScrolling: number
  @Event $userScrolling: (val: number) => void = () => {}

  build() {
    Text(this.item.content)
      .width('100%')
      .fontSize(this.lyricStyle.size)
      .fontWeight(this.lyricStyle.weight)
      .lineHeight(this.lyricStyle.size * 1.3)
      .fontColor(Color.White)
      .opacity(this.index == this.currentLyricIndex ? 1 : 0.35)
      .textAlign(this.lyricStyle.align === 'center' ? TextAlign.Center : TextAlign.Start)
      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
      .padding({ left: 20, right: 20 })
      .scale(this.index === this.currentLyricIndex ?
        { x: 1.0, y: 1.0, centerX: this.lyricStyle.align === 'center' ? '50%' : 0 } :
        { x: 0.9, y: 0.9, centerX: this.lyricStyle.align === 'center' ? '50%' : 0 })
      .onClick(() => {
        PlayControl.seekMusic(this.item.time + 100)
        setTimeout(() => {
          this.$userScrolling(0)
        }, 100)
      })
      .animation({
        duration: 500,
        curve: Curve.Smooth,
        expectedFrameRateRange: {
          expected: 90,
          min: 60,
          max: 90
        }
      })
  }
}
