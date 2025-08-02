import { GlobalStore, Logger, LyricUtils, NowPlayingStore, PlayControl, SCEmitter } from "@handwer/base"
import { Lyric, LyricStyle, LyricStyle_INITIAL } from "@handwer/api_adapter"
import { LazyData } from "@pie/lazy-data"
import { curves, LengthUnit, TextModifier } from "@kit.ArkUI"
import { EmitterUtil } from "@pura/harmony-utils"
import text from "@ohos.graphics.text"

const TAG = '[LyricArea]'

@ComponentV2
export struct LyricComponent {
  @Param miniMode: boolean = false

  nps = NowPlayingStore
  glb = GlobalStore

  @Local firstLoad: boolean = true
  @Local userScrolling: number = 0
  @Local userScrollingInterval: number = 0
  @Local lyric: Lyric[] = []
  @Local isLoading: boolean = false
  @Local needUpdate: boolean = false
  // @Local dataSource: LazyData<Lyric> = new LazyData()
  @Local newLyricEffect: boolean = true

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
    await this.getLyric()
    setTimeout(() => {
      this.scroller.scrollToIndex(NowPlayingStore.currentLyricIndex + 1, false, ScrollAlign.CENTER)
    }, 10)
    this.StartAutoScrollTimer()
  }

  async refreshLyric() {
    Logger.debug(TAG, `lyric loading`)
    this.userScrolling = 0
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
    // this.dataSource.setData(this.lyric)
    // this.dataSource.notifyDataReload()
  }

  @Monitor('nps.currentLyricIndex')
  ToCurrentLyric() {
    if(!this.userScrolling && !this.isLoading) {
      this.scroller.scrollToIndex(this.nps.currentLyricIndex + 1, true, ScrollAlign.CENTER)
    }
  }

  build() {
    List({ scroller: this.scroller }) {
      if(!this.isLoading) {
        ListItem().height('50%')
        if(this.newLyricEffect) {
          ForEach(this.lyric, (item: Lyric, index) => {
            LyricLine({
              miniMode: this.miniMode,
              lyricStyle: this.nps.lyricStyle,
              currentLyricIndex: this.nps.currentLyricIndex,
              userScrolling: this.userScrolling!!,
              index: index,
              item: item
            })
              .clip(false)
              .offset({ y: this.Offset(index) })
              .animation(this.userScrolling ? {
                delay: this.userScrolling ? 0 : this.Delay(index),
                duration: this.userScrolling ? 0 : 600,
                curve: Curve.Smooth,
                expectedFrameRateRange: {
                  expected: 90,
                  min: 60,
                  max: 90
                }
              } : {
                curve: curves.springMotion(0.7, 0.6),
                expectedFrameRateRange: {
                  expected: 90,
                  min: 60,
                  max: 90
                }
              })
              .padding({
                bottom: ((!this.userScrolling
                  ? (index >= this.nps.currentLyricIndex ? this.nps.lyricStyle.size : this.nps.lyricStyle.size * 2)
                  : this.nps.lyricStyle.size * 2) * 0.5)
                //+(this.miniMode ? 10 : 0)
              })
              .animation({ duration: this.userScrolling ? 0 : 300, curve: Curve.Friction })
          })
        } else {
          // ForEach(this.lyric, (item: Lyric, index) => {
          //   LyricLine({
          //     lyricStyle: this.nps.lyricStyle,
          //     currentLyricIndex: this.nps.currentLyricIndex,
          //     userScrolling: this.userScrolling!!,
          //     index: index,
          //     item: item
          //   })
          //     .padding({ bottom: this.nps.lyricStyle.size * 2 })
          // })
        }
        ListItem().height('50%')
      }
    }
    .cachedCount(3)
    .alignListItem(ListItemAlign.End)
    .padding({ top: 30, left: this.nps.lyricStyle.align == TextAlign.Start ? 24 : 0 })
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring)
    .listDirection(Axis.Vertical)
    .scrollBar(BarState.Off)
    .fadingEdge(!this.miniMode, {
      fadingEdgeLength: {
        unit: LengthUnit.PERCENT,
        value: 50
      },
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Move) {
        this.userScrolling = 2
      }
    })
    .onAppear(() => {
      EmitterUtil.onSubscribe(SCEmitter.LyricUpdate,
        () => {
        Logger.debug(TAG, `lyric update triggered`)
        this.refreshLyric()
        })
    })
    .onDisAppear(() => {
      EmitterUtil.unSubscribe(SCEmitter.LyricUpdate)
    })
  }

  Offset(index: number) {
    if(this.userScrolling) return 0
    const LINE_SPACING = this.nps.lyricStyle.size
    const delta = index - this.nps.currentLyricIndex
    let offset = delta > 0 ? delta * LINE_SPACING : 0
    return offset
  }

  Delay(index: number) {
    if(this.userScrolling) return 0
    const delta = index - this.nps.currentLyricIndex
    return Math.max(delta * 80, 0)
  }

}

@ComponentV2
struct LyricLine {
  @Param miniMode: boolean = false
  @Param index: number = 0
  @Param item: Lyric = { time: 0, content: '' }
  @Param currentLyricIndex: number = 0
  @Param lyricStyle: LyricStyle = LyricStyle_INITIAL
  @Param @Require userScrolling: number
  @Event $userScrolling: (val: number) => void = () => {}

  @Local mod: AttributeModifier<TextAttribute> | undefined = new TextModifier()

  get isOnPlay() {
    return this.index == this.currentLyricIndex
  }
  get isAfterPlay() {
    return this.index < this.currentLyricIndex
  }

  @Monitor('miniMode')
  onMiniMode() {
    if (this.miniMode) {
      this.mod = new MTM()
    } else {
      this.mod = new TextModifier()
    }
  }

  aboutToAppear(): void {
    this.onMiniMode()
  }

  build() {
    Text(this.item.content)
      .width('100%')
      .fontSize(this.lyricStyle.size)
      // MINI MODE OVERFLOW
      .attributeModifier(this.mod)
      // --------------------
      .scale({x: this.isOnPlay ? 1 :  this.lyricStyle.onNotPlayScale, y: this.isOnPlay ? 1 : this.lyricStyle.onNotPlayScale})
      .fontWeight(this.isOnPlay ? this.lyricStyle.onPlayWeight : this.lyricStyle.weight)
      .lineHeight(this.lyricStyle.size * 1.3)
      .fontColor(Color.White)
      .foregroundEffect(this.isAfterPlay ? {
        radius: 9
      } : undefined)
      .opacity(this.isOnPlay ? 1 : 0.35)
      .textAlign(this.lyricStyle.align)
      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
      .padding({ left: 20, right: 20 })
      .scale(this.isOnPlay ?
        { x: 1.0, y: 1.0, centerX: this.lyricStyle.align === TextAlign.Center ? '50%' : 0 } :
        { x: 0.9, y: 0.9, centerX: this.lyricStyle.align === TextAlign.Center ? '50%' : 0 })
      .onClick(() => {
        if (this.miniMode) return // MINI MODE no click
        PlayControl.seekMusic(this.item.time + 100)
        setTimeout(() => {
          this.$userScrolling(0)
        }, 100)
      })
      .textShadow(this.isOnPlay ? {
        color: '#ccffffff',
        radius: 12 + (this.miniMode ? -6 : 0)
      } : undefined)
      .clip(false)
      .animation({
        duration: 600,
        curve: Curve.Smooth,
        expectedFrameRateRange: {
          expected: 90,
          min: 60,
          max: 90
        }
      })
  }
}


class MTM implements AttributeModifier<TextAttribute> {
  applyNormalAttribute(instance: TextAttribute): void {
    instance.maxLines(1)
      .textOverflow({overflow: TextOverflow.MARQUEE})
      .marqueeOptions({start: true, fadeout: true})
  }
}