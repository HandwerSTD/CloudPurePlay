import { LightUpIconTextButton, LightUpRoundedButton, UIComponentUtils, LightUpDefaultConfig } from "@handwer/ui_components";
import { ImageTitleWelcomeTemplate, SymbolTitle } from "./CommonTemplate";
import { LengthMetrics } from "@kit.ArkUI";
import { ResponsiveUtil } from "@handwer/base";

@ComponentV2
export struct LightUp {

  @Builder header() {
    SymbolTitle({
      icon: $r('sys.symbol.light_painting'),
      gradientColor: [0xc5a7ee, 0xbfdff2],
    })
  }
  @Builder QuickButtons() {
    Row() {
      List({space: ResponsiveUtil.chooseByWidth([6, 12])}) {
        ListItem().width(ResponsiveUtil.chooseByWidth([14, 12]))
        // HeartMode
        ListItem() {
          LightUpIconTextButton({
            icon: $r('sys.symbol.opticaldisc_badge_heart'),
            title: $r('app.string.Heart_list'),
            lightUpConfig: {
              lightIntensity: 0.5,
              lightHeight: 50
            },
            clickAction: () => {
            }
          })
        }.margin({right: 12})

        ListItem() {
          LightUpIconTextButton({
            icon: UIComponentUtils.getTodayIcon(),
            title: $r('app.string.Daily_recommend'),
            lightUpConfig: {
              lightIntensity: 0.5,
              lightHeight: 50
            },
            clickAction: () => {
            }
          })
        }.margin({right: 12})

        ListItem() {
          LightUpIconTextButton({
            icon: $r('sys.symbol.radiostation'),
            title: $r('app.string.Personal_fm'),
            lightUpConfig: {
              lightIntensity: 0.5,
              lightHeight: 50
            },
            clickAction: () => {
            }
          })
        }.margin({right: 12})
        ListItem().width(0)
      }.fadingEdge(true, {
        fadingEdgeLength: LengthMetrics.percent(10)
      })
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
    }.width('100%').justifyContent(FlexAlign.Center)
  }
  @Builder SmallQuickButtons() {
    Row({space: 12}) {
      LightUpRoundedButton({
        icon: $r('sys.symbol.heart_fill'),
        customFontColor: [Color.White],
        customFontSize: 30,
        customPadding: 12,
        clickAction: () => {
        },
        lightUpConfig: {
          lightIntensity: 1.5,
          lightHeight: 50,
        }
      })
      // 每日推荐
      LightUpRoundedButton({
        icon: $r('sys.symbol.calendar_31_a'),
        customFontColor: [Color.White],
        customFontSize: 30,
        customPadding: 12,
        clickAction: () => {
        },
        lightUpConfig: {
          lightIntensity: 1.5,
          lightHeight: 50,
        }
      })

      // 私人FM
      LightUpRoundedButton({
        icon: $r('sys.symbol.radiostation'),
        customFontColor: [Color.White],
        customFontSize: 30,
        customPadding: 12,
        clickAction: () => {
        },
        lightUpConfig: {
          lightIntensity: 1.5,
          lightHeight: 50,
        }
      })
    }.width('100%').justifyContent(FlexAlign.SpaceEvenly)
  }

  @Builder footer() {
    Column() {

      if (ResponsiveUtil.widthCheck(['sm'])) {
        this.SmallQuickButtons()
      } else {
        this.QuickButtons()
      }
    }.height('30%').justifyContent(FlexAlign.Start)
  }

  build() {
    ImageTitleWelcomeTemplate({
      title: '生长在「光」上',
      subtitle: '一款生长在光上的音乐播放器。基于最新 HarmonyOS 光场效果，让每一次播放都在光影之间流动。纯粹聆听，前所未有的「光」体验。',
      customImage: this.header,
      footer: () => {
        this.footer()
      }
    }).transition(TransitionEffect.OPACITY.animation({duration: 1000, delay: 1000}))
  }
}