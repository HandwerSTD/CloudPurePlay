import { PlayQueue } from "@handwer/api_adapter"
import { GlobalStore, Logger, PlayControl, PlayQueueStore, PlayQueueUtils, SongConvertUtils } from "@handwer/base"
import { LightUpDefaultConfig, LightUpRoundedButton } from "@handwer/ui_components"
import { curves, TextModifier } from "@kit.ArkUI"
import { hdsEffect } from "@kit.UIDesignKit"

@ComponentV2
export struct PlayQueueView {
  pq = PlayQueueStore
  whiteTextMod = new TextModifier().fontColor(Color.White)

  scroller = new Scroller()

  @Monitor('pq.currentQueueIndex')
  onQueueGo() {
    // this.scroller.scrollToIndex(this.pq.currentQueueIndex, true, undefined)
  }

  build() {
    // 白嫖一个 title 而已
    WithTheme({colorMode: ThemeColorMode.DARK}) {
      Navigation() {
        Column() {
          List({space: 12, scroller: this.scroller, initialIndex: this.pq.currentQueueIndex}) {
            ForEach(this.pq.queue, (item: PlayQueue, index) => {
              ListItem() {
                PlayQueueSingleItem({
                  item: item,
                  itemIndex: index
                })
              }
              .transition(TransitionEffect.asymmetric(
                TransitionEffect.OPACITY.animation({duration: 300}),
                TransitionEffect.OPACITY.animation({duration: 300})))
              .onClick(() => {
                PlayControl.playQueue(index)
              })
            })
            ListItem().height(GlobalStore.wd.bottom)
          }
          .divider({
            strokeWidth: 2,
            endMargin: 24
          })
        }
      }
      .margin({top: 12}) // Navigation 默认避让
      .title({
        main: $r('app.string.play_queue'),
        sub: $r('app.string.play_queue_total_num', this.pq.queue.length),
      })
      .titleMode(NavigationTitleMode.Mini)
    }
  }
}

@ComponentV2
export struct PlayQueueSingleItem {
  @Param @Require item: PlayQueue
  @Param @Require itemIndex: number

  moveSpring = curves.springMotion(0.6, 0.8)

  pq = PlayQueueStore
  @Local showLight: boolean = true

  get isNowPlaying() {
    return this.pq.currentQueueIndex === this.itemIndex
  }

  @Local pointLocation: number = 0
  @Local pointLightX: number = 0
  @Local pointLightY: number = 0
  @Local coverArea: Area | undefined = undefined
  pointLightMoveIntervalHandler?: number
  @Builder PointLight() {
    if (this.showLight) {
      Column() {}.height(2).width(2)
      .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
        options: {
          color: Color.White,
          intensity: 0.5,
          height: 100
        }
      }).buildEffect())
      .translate({
        x: this.pointLightX,
        y: this.pointLightY
      })
      .animation({duration: 1500})
    }
  }

  aboutToAppear(): void {
    this.onPlayStateChange()
  }

  @Monitor('pq.currentQueueIndex')
  onPlayStateChange() {
    if (this.isNowPlaying) {
      // 点光源移动
      Logger.debug(`play queue item on light up`)
      this.showLight = true
      this.pointLightMoveIntervalHandler = setInterval(() => {
        this.pointLocation += 1;
        this.pointLocation %= 4;
        switch (this.pointLocation) {
          case 0:
            this.pointLightX = 0;
            this.pointLightY = 0;
            break;
          case 1:
            this.pointLightX = (this.coverArea!.width.valueOf() as number) //+ this.lightOffset
            break;
          case 2:
            // this.pointLightY = (this.coverArea!.height.valueOf() as number) //+ this.lightOffset
            break;
          case 3:
            this.pointLightX = 0;
            break;
        }
      }, 1500)
    } else {
      this.showLight = false
      clearInterval(this.pointLightMoveIntervalHandler)
      this.pointLightMoveIntervalHandler = undefined
    }
  }
  relocatePointLight() {
    if (!this.showLight) return
    switch (this.pointLocation) {
      case 0:
        this.pointLightX = 0;
        this.pointLightY = 0;
        break;
      case 1:
        this.pointLightX = (this.coverArea!.width.valueOf() as number)
        break;
      case 2:
        // this.pointLightY = (this.coverArea!.height.valueOf() as number)
        break;
      case 3:
        this.pointLightX = 0;
        break;
    }
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
          .fontSize(this.isNowPlaying ? 22 : 18)
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
          .fontSize(this.isNowPlaying ? 14 : 14)
          .animation({curve: this.moveSpring})
      }.layoutWeight(1)

      LightUpRoundedButton({
        icon: $r('sys.symbol.xmark'),
        customFontSize: 14,
        customFontWeight: FontWeight.Bold,
        clickAction: () => {
          PlayQueueUtils.queueDelete(this.itemIndex, true)
            .then(() => {
              PlayControl.playQueue(PlayQueueStore.currentQueueIndex)
            })
        },
        lightUpConfig: {
          lightIntensity: 0.8,
          lightHeight: 150
        }
      })
    }.padding(this.isNowPlaying ? {
      left: 6, right: 12, top: 12, bottom: 12
    } : {left: 6, right: 12, top: 6, bottom: 6})
    // .animation({curve: this.moveSpring})
    .margin({left: 6, right: 6, top: 6, bottom: 6})
    .borderRadius(36)
    .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
      illuminatedType: this.isNowPlaying ? hdsEffect.PointLightIlluminatedType.BORDER : hdsEffect.PointLightIlluminatedType.NONE
    }).buildEffect())
    .onAreaChange((_, nw) => {
      this.coverArea = nw
      this.relocatePointLight()
    })
  }


  build() {
    Stack({alignContent: Alignment.Start}) {
      this.PointLight()
      this.MainArea()
    }
  }
}

@Builder
export function PlayQueueViewBuilder() {
  PlayQueueView()
}
