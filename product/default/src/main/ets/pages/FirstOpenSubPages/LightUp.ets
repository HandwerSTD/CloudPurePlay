import { LightUpIconTextButton, LightUpRoundedButton, UIComponentUtils, LightUpDefaultConfig,
  OverrideLightUpStat } from "@handwer/ui_components";
import { ImageTitleWelcomeTemplate, SymbolTitle } from "./CommonTemplate";
import { LengthMetrics } from "@kit.ArkUI";
import { Logger, ResponsiveUtil } from "@handwer/base";

@ComponentV2
export struct LightUp {
  @Param @Require show: boolean
  @Local autoLightIndex: number = -1

  shouldAutoLight(index: number) {
    return this.autoLightIndex === index ? OverrideLightUpStat.ALWAYS_ENABLED : OverrideLightUpStat.NO_OVERRIDE
  }
  updateAutoLight() {
    let original = this.autoLightIndex
    this.autoLightIndex = -1
    setTimeout(() => {
      this.autoLightIndex = (original + 1) % 3;
    }, 1000)
  }

  @Builder header() {
    SymbolTitle({
      icon: $r('sys.symbol.light_painting'),
      gradientColor: [0x02c1f8, 0x025fea],
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
            // overrideLightStat: this.shouldAutoLight(3),
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
            // overrideLightStat: this.shouldAutoLight(4),
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
            // overrideLightStat: this.shouldAutoLight(5),
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
        overrideLightUpStat: this.shouldAutoLight(0),
        lightUpConfig: {
          lightIntensity: 1.5,
          lightHeight: 100,
        }
      })
      // 每日推荐
      LightUpRoundedButton({
        icon: $r('sys.symbol.calendar_31_a'),
        customFontColor: [Color.White],
        customFontSize: 30,
        customPadding: 12,
        overrideLightUpStat: this.shouldAutoLight(1),
        clickAction: () => {
        },
        lightUpConfig: {
          lightIntensity: 1.5,
          lightHeight: 100,
        }
      })

      // 私人FM
      LightUpRoundedButton({
        icon: $r('sys.symbol.radiostation'),
        customFontColor: [Color.White],
        customFontSize: 30,
        customPadding: 12,
        overrideLightUpStat: this.shouldAutoLight(2),
        clickAction: () => {
        },
        lightUpConfig: {
          lightIntensity: 1.5,
          lightHeight: 100,
        }
      })
    }.width('100%').justifyContent(FlexAlign.SpaceEvenly)
  }

  @Local showFooter: boolean = false
  @Builder footer() {
    if (this.showFooter){
      Column({space: 24}) {
        this.SmallQuickButtons()
        this.QuickButtons()
      }.height('30%').justifyContent(FlexAlign.Start)
      .transition(TransitionEffect.OPACITY.animation({duration: 500}))
    }
  }

  build() {
    if (this.show) {
      ImageTitleWelcomeTemplate({
        title: '生长在「光」上',
        subtitle: '一款生长在光上的音乐播放器。基于最新 HarmonyOS 光场效果，让每一次播放都在光影之间流动。纯粹聆听，前所未有的「光」体验。\n\n光场设计元素遍布在《云净听》中，无论是播放按钮，还是封面图片，或是精致歌词，都有「光」的流动，\n\n点击下方按钮，体验「光」。',
        customImage: this.header,
        footer: () => {
          this.footer()
        }
      }).transition(TransitionEffect.OPACITY.animation({duration: 1000, delay: 1000}).combine(TransitionEffect.scale({
        x: 1.2, y: 1.2
      }).animation({duration: 1000, curve: Curve.EaseInOut, delay: 1000})))
        .onAppear(() => {
          setTimeout(() => {
            this.showFooter = true
          }, 2000)
        })
    }
  }
}