import { Logger, NowPlayingStore, PlayControl, PlayQueueStore, PlayQueueUtils, SongConvertUtils } from "@handwer/base"
import { CycleMode, Song } from "@handwer/api_adapter"
import { LightUpRoundedButton } from "@handwer/ui_components"
import { curves } from "@kit.ArkUI"
import { ClickUtil } from "@pura/harmony-utils"
import { WearableEmptyQueueView } from "../components/WearableEmptyQueueView"
import { HdsSnackBar } from "@kit.UIDesignKit"

const nps = NowPlayingStore

@ComponentV2  
export struct WearablePlayQueueView {
  @Param @Require onClose: () => void
  hdsSnackBar = new HdsSnackBar(this.getUIContext())
  
  pq = PlayQueueStore

  get isQueueEmpty() {
    return this.pq.queue.length === 0
  }

  @Builder QueueHeader() {
    Row() {
      Text($r('app.string.play_queue'))
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .layoutWeight(1)

      LightUpRoundedButton({
        icon: $r('sys.symbol.xmark'),
        customFontColor: [Color.White],
        clickAction: () => {
          this.onClose()
        },
        lightUpConfig: {
          lightIntensity: 1,
          lightHeight: 80
        }
      })
      .width(28)
      .height(28)
    }
    .width('100%')
    .padding(12)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  @Builder QueueItem(song: Song, index: number) {
    ListItem() {
      Row({ space: 8 }) {
        // 播放状态指示器
        Column() {
          if (song.id === nps.currentSong.id) {
            Text("♪")
              .fontSize(12)
              .fontColor(Color.White)
              .animation({
                duration: 1000,
                curve: Curve.Ease,
                iterations: -1,
                playMode: PlayMode.Alternate
              })
          } else {
            Text((index + 1).toString())
              .fontSize(10)
              .fontColor(Color.White)
              .opacity(0.6)
          }
        }
        .width(20)
        .justifyContent(FlexAlign.Center)

        // 歌曲信息
        Column({ space: 2 }) {
          Text(song.name)
            .fontSize(12)
            .fontColor(Color.White)
            .fontWeight(song.id === nps.currentSong.id ? FontWeight.Bold : FontWeight.Normal)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Text(SongConvertUtils.getArtists(song.artists))
            .fontSize(10)
            .fontColor(Color.White)
            .opacity(0.7)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 移除按钮
        LightUpRoundedButton({
          icon: $r('sys.symbol.minus'),
          customFontColor: [Color.White],
          clickAction: () => {
            ClickUtil.throttle(() => {
              PlayQueueUtils.queueDelete(index)
            }, 300)
          },
          lightUpConfig: {
            lightIntensity: 0.8,
            lightHeight: 60
          }
        })
        .width(24)
        .height(24)
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .backgroundColor(song.id === nps.currentSong.id ? '#33FFFFFF' : 'transparent')
      .borderRadius(8)
      .animation({
        duration: 300,
        curve: Curve.Ease
      })
    }
    .width('100%')
    .onClick(() => {
      if (song.id !== nps.currentSong.id) {
        PlayControl.playQueue(index)
      }
    })
  }

  build() {
    Column() {
      this.QueueHeader()

      if (this.isQueueEmpty) {
        WearableEmptyQueueView({
          hdsSnackBar: this.hdsSnackBar
        })
        .layoutWeight(1)
      } else {
        List() {
          ForEach(this.pq.queue, (song: Song, index: number) => {
            this.QueueItem(song, index)
          })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .padding({ left: 8, right: 8 })
      }

      // 底部功能按钮
      Row({ space: 12 }) {
        LightUpRoundedButton({
          icon: $r('sys.symbol.shuffle'),
          customFontColor: [Color.White],
          clickAction: () => {
            PlayQueueUtils.changeCycleMode(CycleMode.random)
          },
          lightUpConfig: {
            lightIntensity: 1,
            lightHeight: 80
          }
        })
        .width(32)
        .height(32)

        LightUpRoundedButton({
          icon: $r('sys.symbol.xmark'),
          customFontColor: [Color.White],
          clickAction: () => {
            PlayQueueUtils.cleanQueue()
          },
          lightUpConfig: {
            lightIntensity: 1,
            lightHeight: 80
          }
        })
        .width(32)
        .height(32)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .padding(12)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#CC000000') // 半透明黑色背景
    .borderRadius(16)
    .clip(true)
  }
}
