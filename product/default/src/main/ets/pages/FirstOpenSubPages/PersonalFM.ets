import { LightUpIconTextButton, LightUpRoundedButton, UIComponentUtils, LightUpDefaultConfig } from "@handwer/ui_components";
import { ImageTitleWelcomeTemplate, SymbolTitle } from "./CommonTemplate";
import { LengthMetrics } from "@kit.ArkUI";
import { ResponsiveUtil } from "@handwer/base";

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