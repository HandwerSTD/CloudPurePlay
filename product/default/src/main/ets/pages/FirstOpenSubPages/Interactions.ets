import {
  CommonListItem,
  LightUpIconTextButton, LightUpLinedContainer, LightUpRoundedButton,LightUpDefaultConfig
} from "@handwer/ui_components";
import { ImageTitleWelcomeTemplate, SymbolTitle } from "./CommonTemplate";
import { hdsEffect } from "@kit.UIDesignKit";

@ComponentV2
export struct MultiInteractions {


  @Builder header() {
    SymbolTitle({
      icon: $r('sys.symbol.wand_and_stars'),
      gradientColor: [0x02c1f8, 0x025fea],
    })
  }
  // TODO: 开关
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

  @Builder footer() {
    Stack({alignContent: Alignment.TopEnd}) {
      Row() {
        Swiper() {
          this.featureCard($r('sys.symbol.dual_phone_pairing'), $r('app.string.first_open_page__interaction_share_feature'))
          this.featureCard($r('sys.symbol.pencil_waveform'), $r('app.string.first_open_page__interaction_stylus_feature'))
          this.featureCard($r('sys.symbol.hand_stars'), $r('app.string.first_open_page__interaction_hand_recognition_feature'))
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
          icon: $r('sys.symbol.phone_2'),
          title: $r('app.string.first_open_page__interaction_feature_disclaimer'),
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
      title: $r('app.string.first_open_page__interaction_title'),
      subtitle: $r('app.string.first_open_page__interaction_subtitle'),
      customImage: this.header,
      footer: () => {
        this.footer()
      }
    })
  }
}