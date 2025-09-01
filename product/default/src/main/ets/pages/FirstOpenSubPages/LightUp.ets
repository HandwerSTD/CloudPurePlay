import { LightUpIconTextButton, LightUpRoundedButton, UIComponentUtils, LightUpDefaultConfig,
  OverrideLightUpStat } from "@handwer/ui_components";
import { ImageTitleWelcomeTemplate, SymbolTitle } from "./CommonTemplate";
import { LengthMetrics } from "@kit.ArkUI";
import { Logger, ResponsiveUtil } from "@handwer/base";

@ComponentV2
export struct LightUp {
  @Param @Require show: boolean

  @Builder header() {
    SymbolTitle({
      icon: $r('sys.symbol.light_painting'),
      gradientColor: [0x02c1f8, 0x025fea],
    })
  }
  @Builder QuickButtons() {
    Column({space: 12}) {
      Row({space: 12}) {
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
            lightHeight: 100,
          }
        })

        LightUpRoundedButton({
          icon: $r('sys.symbol.play_circle_badge_music_note'),
          customFontColor: [Color.White],
          customFontSize: 30,
          customPadding: 12,
          clickAction: () => {
          },
          lightUpConfig: {
            lightIntensity: 1.5,
            lightHeight: 100,
          }
        })

      }
      Row({space: 12}) {
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
            lightHeight: 100,
          }
        })
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

        LightUpRoundedButton({
          icon: $r('sys.symbol.heart_fill'),
          customFontColor: [Color.White],
          customFontSize: 30,
          customPadding: 12,
          clickAction: () => {
          },
          lightUpConfig: {
            lightIntensity: 1.5,
            lightHeight: 100,
          }
        })
      }
      Text() {
        Span('点击按钮，体验')
        Span('「光」')
          .fontWeight(FontWeight.Bolder)
          .textShadow({
            color: '#88ffffff',
            radius: 12,
            offsetY: 4
          })

      }.fontColor(Color.White)
    }.width('100%').justifyContent(FlexAlign.Center)
  }

  @Builder CoverLight() {
    Column({space: 24}) {
      Blank().height(0)
      Stack() {
        SymbolTitle({
          icon: $r('sys.symbol.play_circle_badge_music_note'),
          gradientColor: [0xf4aa8d, 0xf19071]
        }).offset({x: -80}).scale({x:0.9, y: 0.9, centerX: '100%'})
        SymbolTitle({
          icon: $r('sys.symbol.music_note_list'),
          gradientColor: [0xef8ba6, 0xe25778]
        })
        SymbolTitle({
          icon: $r('sys.symbol.radiostation'),
          gradientColor: [0x96c2e2, 0x6fa3d0]
        }).offset({x: 80}).scale({x: 1.1, y: 1.1, centerX: '0%'})
      }.alignContent(Alignment.Center)
      Text('音乐封面发光，光影源自色彩本身，随着节奏与氛围轻微流动，让聆听更沉浸。')
        .fontColor(Color.White)
        .padding(24)
    }.justifyContent(FlexAlign.Center)
  }

  @Local showFooter: boolean = false
  @Builder footer() {
    if (this.showFooter) {
      Row() {
        Swiper() {
          this.QuickButtons()
          this.CoverLight()
        }.height(280).width('100%')
        .autoPlay(true)
        .interval(4000)
        .indicator(false)
      }
      // .padding({top: 24, bottom: 24})
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.play_list_single_item_bg'))
      .borderRadius(24)
      // .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
      //   illuminatedType: hdsEffect.PointLightIlluminatedType.CONTENT
      // }).buildEffect())
    }
  }

  build() {
    if (this.show) {
      ImageTitleWelcomeTemplate({
        title: '生长在「光」上',
        subtitle: '一款生长在光上的音乐播放器。基于最新 HarmonyOS 光场效果，让每一次播放都在光影之间流动。纯粹聆听，前所未有的「光」体验。\n\n光场设计元素遍布在《云净听》中，无论是播放按钮，还是封面图片，或是精致歌词，都有「光」的流动。',
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