import { FeaturedPlayUtils } from "@handwer/base"
import {  ActionButton, UIComponentUtils} from "@handwer/wearable_ui_components"
import { promptAction } from "@kit.ArkUI"

@ComponentV2
export struct WearableEmptyQueueView {

  get todayIcon() {
    return UIComponentUtils.getTodayIcon()
  }

  build() {
    Column({ space: 18 }) { // 手表上使用更紧凑的间距
      // 空队列图标
      Column() {
        SymbolGlyph($r('sys.symbol.list_xmark'))
          .fontSize(32) // 手表上使用较小的图标
          .fontColor([Color.White])
          .opacity(0.6)
      }
      .width(60) // 手表上使用较小的尺寸
      .height(60)
      .borderRadius(30)
      .backgroundColor($r('sys.color.comp_background_secondary'))
      .justifyContent(FlexAlign.Center)
      .shadow({
        radius: 12,
        color: '#22ffffff',
        offsetX: 0,
        offsetY: 3
      })

      // 标题
      Column({ space: 6 }) {
        Text($r('app.string.common_empty_content'))
          .fontSize(14) // 手表上使用较小的字体
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Center)

      // 快速开始按钮组 - 手表上垂直排列
      Column({ space: 10 }) {
        // 我喜欢的音乐
         ActionButton({
          icon: $r('sys.symbol.heart_fill'),
          customFontColor: [Color.White],
          clickAction: () => {
            FeaturedPlayUtils.playHeartMode((icon, msg) => {
              promptAction.openToast({message: msg})
            })
          },
        })
        .width(36)
        .height(36)

        // 每日推荐
         ActionButton({
          icon: this.todayIcon,
          customFontColor: [Color.White],
          clickAction: () => {
            FeaturedPlayUtils.playDailySongs((icon, msg) => {
              promptAction.openToast({message: msg})
            }, this.todayIcon)
          },
        })
        .width(36)
        .height(36)

        // 私人FM
         ActionButton({
          icon: $r('sys.symbol.radiostation'),
          customFontColor: [Color.White],
          clickAction: () => {
            FeaturedPlayUtils.playPersonalizedFM((icon, msg) => {
              promptAction.openToast({message: msg})
            })
          },
        })
        .width(36)
        .height(36)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding(16) // 手表上使用较小的内边距
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
