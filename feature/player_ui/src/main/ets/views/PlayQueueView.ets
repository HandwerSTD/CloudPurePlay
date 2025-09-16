import { PlayQueue } from "@handwer/api_adapter"
import { GlobalStore, Logger,
  NowPlayingStore,
  PlayControl, PlayQueueStore, PlayQueueUtils,
  PlaySourceDataType,
  SongConvertUtils } from "@handwer/base"
import { LightUpDefaultConfig, LightUpRoundedButton } from "@handwer/ui_components"
import { curves, TextModifier } from "@kit.ArkUI"
import { hdsEffect, HdsSnackBar } from "@kit.UIDesignKit"
import { EmptyQueueView } from "../components/EmptyQueueView"

@ComponentV2
export struct PlayQueueView {

  pq = PlayQueueStore

  scroller = new Scroller()

  @Monitor('pq.currentQueueIndex')
  onQueueGo() {
    // this.scroller.scrollToIndex(this.pq.currentQueueIndex, true, undefined)
  }

  get PlayModeName() {
    if (NowPlayingStore.isPersonalFM) return $r('app.string.Personal_fm')
    if (NowPlayingStore.isHeartMode) return $r('app.string.Heart_list')
    return $r('app.string.play_queue_total_num', this.pq.queue.length)
  }

  get isQueueEmpty() {
    return this.pq.queue.length === 0
  }

  build() {
    // 白嫖一个 title 而已
    WithTheme({colorMode: ThemeColorMode.DARK}) {
      Navigation() {
        Column() {
          if (this.isQueueEmpty) {
            // 空队列状态
            EmptyQueueView({
              hdsSnackBar: new HdsSnackBar(this.getUIContext()),
            }).transition(TransitionEffect.OPACITY.animation({duration: 500}))
          } else {
            // 正常队列列表
            List({space: 12, scroller: this.scroller, initialIndex: Math.max(this.pq.currentQueueIndex - 1, 0)}) {
              ForEach(this.pq.queue, (item: PlayQueue, index) => {
                ListItem() {
                  PlayQueueSingleItem({
                    item: item,
                    itemIndex: index,
                  })
                }
                .transition(TransitionEffect.asymmetric(
                  TransitionEffect.OPACITY.animation({duration: 300}),
                  TransitionEffect.OPACITY.animation({duration: 300})))
                .onClick(() => {
                  if (this.pq.currentQueueIndex !== index) {
                    PlayControl.playQueue(index)
                  }
                })
                .clickEffect({
                  level: ClickEffectLevel.LIGHT
                })
              })
              ListItem().height(GlobalStore.wd.bottom)
            }
            .divider({
              strokeWidth: 2,
              endMargin: 24
            })
            // .padding({left: 12, right: 12})
          }
        }
      }
      .margin({top: 12}) // Navigation 默认避让
      .title({
        main: $r('app.string.play_queue'),
        sub: this.isQueueEmpty ? $r('app.string.common_empty_content') : this.PlayModeName,
      })
      .titleMode(NavigationTitleMode.Mini)
    }
  }
}

@ComponentV2
export struct PlayQueueSingleItem {
  @Param @Require item: PlayQueue
  @Param @Require itemIndex: number
  @Param showLight: boolean = true

  moveSpring = curves.springMotion(0.6, 0.8)

  pq = PlayQueueStore

  get isNowPlaying() {
    return this.pq.currentQueueIndex === this.itemIndex
  }
  get isNearNowPlay() {
    return Math.abs(this.pq.currentQueueIndex - this.itemIndex) <= 1
  }

  @Builder MainArea() {

    Row() {
      Column() {
        Text(this.item.song.name)
          .width('90%')
          .textAlign(TextAlign.Start)
          .textOverflow({
            overflow: TextOverflow.MARQUEE
          })
          .marqueeOptions({
            start: true,
            fadeout: true
          })
          .fontColor(Color.White)
          .fontWeight(this.isNowPlaying ? FontWeight.Bold : FontWeight.Medium)
          .fontSize(18)
          .animation({curve: this.moveSpring})
        Text(SongConvertUtils.getArtists(this.item.song.artists))
          .width('90%')
          .textAlign(TextAlign.Start)
          .textOverflow({
            overflow: TextOverflow.MARQUEE
          })
          .marqueeOptions({
            start: true,
            fadeout: true
          })
          .fontColor(Color.White)
          .fontSize(14)
          .animation({curve: this.moveSpring})
      }.layoutWeight(1)

      if (this.item.song.customAPI) {
        Text('来自外部')
          .fontColor(Color.White)
          .padding({right: 12})
      }
      if (!NowPlayingStore.isPersonalFM) {
        LightUpRoundedButton({
          icon: $r('sys.symbol.xmark'),
          customFontSize: 14,
          customFontWeight: FontWeight.Bold,
          clickAction: () => {
            PlayQueueUtils.queueDelete(this.itemIndex)
          },
          customFontColor: [Color.White],
          lightUpConfig: {
            lightIntensity: 2,
            lightHeight: 150
          }
        })
      }
    }.padding({left: 6, right: 12, top: 12, bottom: 12})
    // .animation({curve: this.moveSpring})
    .margin({left: 12, right: 12})
    .border(this.isNowPlaying ? {
      radius: 16,
      color: Color.White,
      width: 1
    } : {
      radius: 16,
      width: 0
    })
    .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
      illuminatedType:
        this.isNearNowPlay? hdsEffect.PointLightIlluminatedType.BORDER
          : hdsEffect.PointLightIlluminatedType.NONE,
    }).buildEffect())
    .animation({duration: 300})
    .backgroundColor(this.isNowPlaying ? $r('sys.color.comp_background_tertiary') : undefined)

    // .onAreaChange((_, nw) => {
    //   this.coverArea = nw
    //   this.relocatePointLight()
    // })
  }

  @Builder DualEndPointLight() {
    Row() {
      ForEach([1,2,3,4,5], () => {
        Column() {}.height(1).width(1).opacity(0)
        .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
          illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER_CONTENT,
          options: {
            color: Color.White,
            intensity: this.isNowPlaying && this.showLight ? 1 : 0,
            height: 80
          }
        }).buildEffect())
        .animation({ duration: 300 })
      })
    }.width('100%').justifyContent(FlexAlign.SpaceAround)
  }


  build() {
    Stack({alignContent: Alignment.Start}) {
      // this.PointLight()
      this.DualEndPointLight()
      this.MainArea()
    }
  }
}

@Builder
export function PlayQueueViewBuilder() {
  PlayQueueView()
}
