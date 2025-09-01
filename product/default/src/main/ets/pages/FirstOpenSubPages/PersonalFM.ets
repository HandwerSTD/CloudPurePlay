import {
  LightUpRoundedButton,
  LightUpDefaultConfig,
  LightUpLinedContainer,
  CommonListItem
} from "@handwer/ui_components"
import { SymbolTitle, ImageTitleWelcomeTemplate } from "./CommonTemplate"
import { hdsEffect } from "@kit.UIDesignKit"


@ComponentV2
export struct PersonalFM {

  @Builder header() {
    SymbolTitle({
      icon: $r('sys.symbol.radiostation'),
      gradientColor: [0x912ecd, 0x4ecbfd],
    })
  }

  @Builder featureCard(symbol: Resource, msg: ResourceStr) {
    Column() {

      Blank().height(24)
      SymbolTitle({
        icon: symbol,
        gradientColor: [0xe4b7d4, 0xbc97d4]
      })
      Text(msg)
        .fontColor(Color.White)
        .padding(24)
    }.height(250).width('100%')
  }

  @Builder customFooter() {
    Stack({alignContent: Alignment.TopEnd}) {
      Row() {
        Swiper() {
          this.featureCard($r('sys.symbol.radiostation'), $r('app.string.first_open_page_personal_fm_desc'))
          this.featureCard($r('sys.symbol.heart'), $r('app.string.first_open_page_heart_mode_desc'))
          this.featureCard($r('sys.symbol.calendar_31_a'), $r('app.string.first_open_page_daily_recommend_desc'))
        }.autoPlay(true)
      }.width('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.play_list_single_item_bg'))
      .borderRadius(24)
      this.overlayInfoButton()
    }
  }

  @Builder overlayInfoButton() {
    LightUpRoundedButton({
      icon: $r('sys.symbol.info_circle'),
      clickAction: () => {
        this.showInfoMenu = !this.showInfoMenu
      },
      lightUpConfig: LightUpDefaultConfig
    }).translate({x: -12, y: 12})
      .bindContextMenu(this.showInfoMenu!!, this.infoMenu, {
        backgroundBlurStyle: BlurStyle.BACKGROUND_THICK,
        hapticFeedbackMode: HapticFeedbackMode.AUTO,
        placement: Placement.Right
      })
  }


  @Local showInfoMenu: boolean = false
  @Builder infoMenu() {
    Column() {
      LightUpLinedContainer() {
        CommonListItem({
          icon: $r('sys.symbol.radiostation'),
          title: $r('app.string.first_open_page_personal_fm_info'),
          trailing: () => {}
        })
      }
      LightUpLinedContainer() {
        CommonListItem({
          icon: $r('sys.symbol.heart_fill'),
          title: $r('app.string.first_open_page_heart_mode_info'),
          trailing: () => {}
        })
      }
      LightUpLinedContainer() {
        CommonListItem({
          icon: $r('sys.symbol.calendar_31_a'),
          title: $r('app.string.first_open_page_daily_recommend_info'),
          trailing: () => {}
        })
      }
    }.borderRadius(24).margin(2)
    .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
      illuminatedType: hdsEffect.PointLightIlluminatedType.BORDER
    }).buildEffect())
  }

  build() {
    ImageTitleWelcomeTemplate({
      title: $r('app.string.first_open_page_instant_play_title'),
      subtitle: $r('app.string.first_open_page_instant_play_desc'),
      customImage: this.header,
      footer: () => {
        this.customFooter()
      }
    })
  }
}