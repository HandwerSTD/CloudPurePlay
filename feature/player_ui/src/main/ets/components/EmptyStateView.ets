import { FeaturedPlayUtils, ResponsiveUtil, Settings, SCPref } from "@handwer/base"
import { LightUpRoundedButton, LightUpConfig, SnackBarUtils, UIComponentUtils,
  LightUpIconTextButton } from "@handwer/ui_components"
import { curves, LengthMetrics, SymbolGlyphModifier } from "@kit.ArkUI"
import { HdsSnackBar } from "@kit.UIDesignKit"

const LIGHT_EMPTY_BTN_CONFIG: LightUpConfig = {
  lightIntensity: 2,
  lightHeight: 200,
  lightBloom: 0.5
}

@ComponentV2
export struct EmptyStateView {
  @Param @Require hdsSnackBar: HdsSnackBar
  @Param @Require onExploreClick: () => void
  
  get todayIcon() {
    return UIComponentUtils.getTodayIcon()
  }

  build() {
    Column({ space: 32 }) {
      // 空状态图标和提示
      Column({ space: 16 }) {
        // 大图标
        Column() {
          SymbolGlyph($r('sys.symbol.music_note_list'))
            .fontSize(80)
            .fontColor([Color.White])
            .opacity(0.6)
        }
        .width(120)
        .height(120)
        .borderRadius(60)
        .backgroundColor($r('sys.color.comp_background_secondary'))
        .justifyContent(FlexAlign.Center)
        .shadow({
          radius: 24,
          color: '#33ffffff',
          offsetX: 0,
          offsetY: 8
        })
        .animation({
          duration: 2000,
          curve: curves.springMotion(),
          iterations: -1,
          playMode: PlayMode.Alternate
        })

        // 标题和描述
        Column({ space: 8 }) {
          Text($r('app.string.not_playing'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
        }
        .alignItems(HorizontalAlign.Center)
      }
      .alignItems(HorizontalAlign.Center)

      // 快速开始按钮组
      Column({ space: 16 }) {
        // 探索页面按钮
        LightUpIconTextButton({
          icon: $r('sys.symbol.house'),
          title: $r('app.string.Explore'),
          clickAction: () => {
            this.onExploreClick?.()
          },
          lightUpConfig: LIGHT_EMPTY_BTN_CONFIG,
          // useFullWidth: true
        })
        // .maxWidth(300)

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
              lightBloom: 0.3
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
              lightBloom: 0.3
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
              lightBloom: 0.3
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

@ComponentV2
export struct EmptyStateViewBar {
  hdsSnackBar = new HdsSnackBar(this.getUIContext())

  get todayIcon() {
    return UIComponentUtils.getTodayIcon()
  }

  build() {
    Row() {
      Text($r('app.string.not_playing'))
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .opacity(0.7)
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
      Row({space: 12}) {
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
    }
    .width('100%')
    .padding({left: 24,
      right: 24,
      top: 8, bottom: 8})
  }
}
