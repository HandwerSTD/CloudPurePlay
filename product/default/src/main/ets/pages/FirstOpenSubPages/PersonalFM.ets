import { LightUpIconTextButton, LightUpRoundedButton, UIComponentUtils, LightUpDefaultConfig,
  LightUpLinedContainer,
  CommonListItem} from "@handwer/ui_components";
import { ImageTitleWelcomeTemplate, SymbolTitle } from "./CommonTemplate";
import { LengthMetrics, Position } from "@kit.ArkUI";
import { ResponsiveUtil } from "@handwer/base";
import { hdsEffect } from "@kit.UIDesignKit";

@ComponentV2
export struct PersonalFM {

  @Builder header() {
    SymbolTitle({
      icon: $r('sys.symbol.radiostation'),
      gradientColor: [0x912ecd, 0x4ecbfd],
    })
  }

  @Builder featureCard(symbol: Resource, msg: string) {
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
          this.featureCard($r('sys.symbol.radiostation'), '私人FM，无需选择，音乐自行流动。一首接一首，带来无尽惊喜。')
          this.featureCard($r('sys.symbol.heart'), '心动模式，一键播放，尽是心动，只播放你最爱的歌。')
          this.featureCard($r('sys.symbol.calendar_31_a'), '每日推荐，每天不同，每天遇见新的聆听。')
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
          title: '私人FM：基于随机算法，从整个音乐库中随机挑选歌曲进行播放',
          trailing: () => {}
        })
      }
      LightUpLinedContainer() {
        CommonListItem({
          icon: $r('sys.symbol.heart_fill'),
          title: '心动模式：一键播放“我喜欢的音乐”歌单，无算法推荐',
          trailing: () => {}
        })
      }
      LightUpLinedContainer() {
        CommonListItem({
          icon: $r('sys.symbol.calendar_31_a'),
          title: '每日推荐：基于算法，以日期为随机种子在音乐库中挑选歌曲组成歌单',
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
      title: '开屏即听，无限推荐',
      subtitle: '启动应用即播放，少一步繁琐，多一点音乐。多种自动播放模式，无限推荐歌曲播放，始终新鲜。',
      customImage: this.header,
      footer: () => {
        this.customFooter()
      }
    })
  }
}