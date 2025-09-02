import { FeaturedPlayUtils } from "@handwer/base"
import {  ActionButton, ActionIconTextButton, UIComponentUtils} from "@handwer/wearable_ui_components"
import { curves, LengthMetrics, SymbolGlyphModifier, promptAction, ArcScrollBar } from "@kit.ArkUI"

@ComponentV2
export struct WearableEmptyStateView {
  @Param @Require onExploreClick: () => void
  
  get todayIcon() {
    return UIComponentUtils.getTodayIcon()
  }

  build() {
    Scroll() {
      Column({ space: 24 }) { // 手表上使用更紧凑的间距
        // 空状态图标和提示
        Column({ space: 12 }) {
          // 大图标
          Column() {
            SymbolGlyph($r('sys.symbol.music_note_list'))
              .fontSize(48) // 手表上使用较小的图标
              .fontColor([Color.White])
              .opacity(0.6)
          }
          .width(80) // 手表上使用较小的尺寸
          .height(80)
          .borderRadius(40)
          .backgroundColor($r('sys.color.comp_background_secondary'))
          .justifyContent(FlexAlign.Center)
          .shadow({
            radius: 16,
            color: '#33ffffff',
            offsetX: 0,
            offsetY: 6
          })
          .animation({
            duration: 2000,
            curve: curves.springMotion(),
            iterations: -1,
            playMode: PlayMode.Alternate
          })

          // 标题
          Column({ space: 6 }) {
            Text($r('app.string.not_playing'))
              .fontSize(18) // 手表上使用较小的字体
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .textAlign(TextAlign.Center)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .alignItems(HorizontalAlign.Center)
        }
        .alignItems(HorizontalAlign.Center)

        // 快速开始按钮组 - 手表上垂直排列
        Column({ space: 12 }) {
          // 探索页面按钮
          ActionIconTextButton({
            icon: $r('sys.symbol.house'),
            title: $r('app.string.Explore'),
            clickAction: () => {
              this.onExploreClick?.()
            },
          })

          // 快速播放按钮行 - 手表上改为列
          Column({ space: 8 }) {
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
              .width(40)
              .height(40)

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
              .width(40)
              .height(40)

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
              .width(40)
              .height(40)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding(16) // 手表上使用较小的内边距
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }
}

// 手表版本的紧凑空状态栏
@ComponentV2
export struct WearableEmptyStateViewBar {

  get todayIcon() {
    return UIComponentUtils.getTodayIcon()
  }

  build() {
    Column() {
      Text($r('app.string.not_playing'))
        .fontSize(14) // 手表上使用较小的字体
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .opacity(0.7)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row({space: 8}) { // 手表上使用更紧凑的间距
         ActionButton({
          icon: $r('sys.symbol.heart_fill'),
          customFontColor: [Color.White],
          clickAction: () => {
            FeaturedPlayUtils.playHeartMode((icon, msg) => {
              promptAction.openToast({message: msg})
            })
          },
        })
        .width(32)
        .height(32)

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
        .width(32)
        .height(32)

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
        .width(32)
        .height(32)
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ top: 8 })
    }
    .width('100%')
    .padding({
      left: 12,
      right: 12,
      top: 6,
      bottom: 6
    })
  }
}
