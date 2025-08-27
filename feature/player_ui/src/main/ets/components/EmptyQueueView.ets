import { FeaturedPlayUtils, ResponsiveUtil } from "@handwer/base"
import { LightUpRoundedButton, LightUpConfig, SnackBarUtils, UIComponentUtils,
  LightUpIconTextButton,
  LightUpDefaultConfig} from "@handwer/ui_components"
import { curves, SymbolGlyphModifier } from "@kit.ArkUI"
import { HdsSnackBar } from "@kit.UIDesignKit"

const LIGHT_QUEUE_EMPTY_CONFIG: LightUpConfig = {
  lightIntensity: 1.5,
  lightHeight: 150,
  lightBloom: 0.3
}

@ComponentV2
export struct EmptyQueueView {
  @Param @Require hdsSnackBar: HdsSnackBar

  get todayIcon() {
    return UIComponentUtils.getTodayIcon()
  }

  build() {
    Column({ space: 24 }) {
      // 空队列图标
      Column() {
        SymbolGlyph($r('sys.symbol.list_xmark'))
          .fontSize(48)
          .fontColor([Color.White])
          .opacity(0.6)
      }
      .width(80)
      .height(80)
      .borderRadius(40)
      .backgroundColor($r('sys.color.comp_background_secondary'))
      .justifyContent(FlexAlign.Center)
      .shadow({
        radius: 16,
        color: '#22ffffff',
        offsetX: 0,
        offsetY: 4
      })

      // 标题和描述
      Column({ space: 8 }) {
        Text($r('app.string.common_empty_content'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
      }
      .alignItems(HorizontalAlign.Center)

      // 快速开始按钮组
      Column({ space: 16 }) {
        // 快速播放按钮行
        Row({ space: 12 }) {
          // 我喜欢的音乐
          LightUpRoundedButton({
            icon: $r('sys.symbol.heart_fill'),
            customFontColor: [Color.White],
            clickAction: () => {
              FeaturedPlayUtils.playHeartMode((icon, msg) => {
                if (this.hdsSnackBar) {
                  SnackBarUtils.showMessage(this.hdsSnackBar, icon, msg)
                }
              })
            },
            lightUpConfig: {
              lightIntensity: 1.5,
              lightHeight: 150,
            }
          })
          // 每日推荐
          LightUpRoundedButton({
            icon: this.todayIcon,
            customFontColor: [Color.White],
            clickAction: () => {
              FeaturedPlayUtils.playDailySongs((icon, msg) => {
                if (this.hdsSnackBar) {
                  SnackBarUtils.showMessage(this.hdsSnackBar, icon, msg)
                }
              }, this.todayIcon)
            },
            lightUpConfig: {
              lightIntensity: 1.5,
              lightHeight: 150,
            }
          })

          // 私人FM
          LightUpRoundedButton({
            icon: $r('sys.symbol.radiostation'),
            customFontColor: [Color.White],
            clickAction: () => {
              FeaturedPlayUtils.playPersonalizedFM((icon, msg) => {
                if (this.hdsSnackBar) {
                  SnackBarUtils.showMessage(this.hdsSnackBar, icon, msg)
                }
              })
            },
            lightUpConfig: {
              lightIntensity: 1.5,
              lightHeight: 150,
            }
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
