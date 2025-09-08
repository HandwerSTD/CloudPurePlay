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
          this.featureCard($r('sys.symbol.dual_phone_pairing'), '启动分享后，碰一碰或隔空抓取，即可分享音乐配置或当前播放的歌曲。有趣就要一起分享，分享也要更有趣。')
          this.featureCard($r('sys.symbol.pencil_waveform'), '双击手写笔即可切歌，轻捏手写笔即可控制播放，手写笔化身 DJ 台。')
          this.featureCard($r('sys.symbol.hand_stars'), '智能左右手识别，导航栏跟着握持手，无论左右手都舒服。')
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
          title: '部分功能需要机型、系统版本等支持，最终体验请以实际为准。',
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
      title: '音乐更灵动，交互更智慧',
      subtitle: '基于 HarmonyOS 多模态感知，为你带来更有趣、更智慧的操作体验。分享歌曲，碰一碰即可发送，一抓一放即可传输；控制音乐播放，更只需提笔轻触。直观、自然，却又充满惊喜。',
      customImage: this.header,
      footer: () => {
        this.footer()
      }
    })
  }
}