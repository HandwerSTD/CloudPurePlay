import { NowPlayingStore, PlayControl, PlayQueueStore, PlayQueueUtils, SongConvertUtils } from "@handwer/base"
import { CycleMode, PlayQueue, Song } from "@handwer/api_adapter"
import {  ActionButton, ArcConst } from "@handwer/wearable_ui_components"
import { ClickUtil } from "@pura/harmony-utils"
import { WearableEmptyQueueView } from "../components/WearableEmptyQueueView"
import { ArcListItem, ArcList, ArcListAttribute, ArcListItemAttribute, LengthMetrics } from "@kit.ArkUI"

const nps = NowPlayingStore

@ComponentV2  
export struct WearablePlayQueueView {
  @Param @Require onClose: () => void
  
  pq = PlayQueueStore

  get isQueueEmpty() {
    return this.pq.queue.length === 0
  }

  @Builder QueueItem(song: PlayQueue, index: number) {
    ArcListItem() {
      Row({ space: 8 }) {
        // 播放状态指示器
        Column() {
            Text((index + 1).toString())
              .fontSize(10)
              .fontColor(Color.White)
              .opacity(0.6)
        }
        .width(20)
        .justifyContent(FlexAlign.Center)

        // 歌曲信息
        Column({ space: 2 }) {
          Text(song.song.name)
            .fontSize(12)
            .fontColor(Color.White)
            .fontWeight(song.song.id === nps.currentSong.id ? FontWeight.Bold : FontWeight.Normal)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Text(SongConvertUtils.getArtists(song.song.artists))
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
         ActionButton({
          icon: $r('sys.symbol.xmark'),
           customFontSize: 14,
          customFontColor: [Color.White],
          clickAction: () => {
            ClickUtil.throttle(() => {
              PlayQueueUtils.queueDelete(index)
            }, 300)
          },
        })
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8, bottom: 8 })
      .backgroundColor(song.song.id === nps.currentSong.id ? '#66FFFFFF' : '#33ffffff')
      .borderRadius(666)
      .animation({
        duration: 300,
        curve: Curve.Ease
      })
    }
    .width(ArcConst.ARC_LIST_W)
    .onClick(() => {
      if (song.song.id !== nps.currentSong.id) {
        PlayControl.playQueue(index)
      }
    })
  }

  build() {
    Column() {

      if (this.isQueueEmpty) {
        WearableEmptyQueueView()
        .layoutWeight(1)
      } else {
        ArcList({initialIndex: this.pq.currentQueueIndex}) {
          ForEach(this.pq.queue, (song: PlayQueue, index: number) => {
            this.QueueItem(song, index)
          })
        }
        .width('100%')
        .space(LengthMetrics.px(30))
        .defaultFocus(true)
      }

      // 底部功能按钮
      // Row({ space: 12 }) {
      //    ActionButton({
      //     icon: $r('sys.symbol.shuffle'),
      //     customFontColor: [Color.White],
      //     clickAction: () => {
      //       PlayQueueUtils.changeCycleMode(CycleMode.random)
      //     },
      //   })
      //   .width(32)
      //   .height(32)
      //
      //    ActionButton({
      //     icon: $r('sys.symbol.xmark'),
      //     customFontColor: [Color.White],
      //     clickAction: () => {
      //       PlayQueueUtils.cleanQueue()
      //     },
      //   })
      //   .width(32)
      //   .height(32)
      // }
      // .width('100%')
      // .justifyContent(FlexAlign.SpaceEvenly)
      // .padding(12)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#CC000000') // 半透明黑色背景
    .borderRadius(16)
    .clip(true)
  }
}
