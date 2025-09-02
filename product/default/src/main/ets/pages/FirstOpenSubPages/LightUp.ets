import { LightUpIconTextButton, LightUpRoundedButton
} from "@handwer/ui_components";
import { ImageTitleWelcomeTemplate, SymbolTitle } from "./CommonTemplate";

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
        Span($r('app.string.first_open_page_light_experience_prefix'))
        Span($r('app.string.first_open_page_light_word'))
          .fontWeight(FontWeight.Bolder)
          .textShadow({
            color: '#88ffffff',
            radius: 12,
            offsetY: 4
          })

      }.fontColor(Color.White).margin({top: 12})
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
      Text($r('app.string.first_open_page_cover_light_desc'))
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
      .transition(TransitionEffect.OPACITY.animation({duration: 500}))
    }
  }

  build() {
    if (this.show) {
      ImageTitleWelcomeTemplate({
        title: $r('app.string.first_open_page_light_up_title'),
        subtitle: $r('app.string.first_open_page_light_up_desc'),
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