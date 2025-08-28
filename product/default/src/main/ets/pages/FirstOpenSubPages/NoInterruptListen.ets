import { LightUpIconTextButton, LightUpRoundedButton, UIComponentUtils, LightUpDefaultConfig } from "@handwer/ui_components";
import { ImageTitleWelcomeTemplate, SymbolTitle } from "./CommonTemplate";
import { LengthMetrics } from "@kit.ArkUI";
import { ResponsiveUtil } from "@handwer/base";

@ComponentV2
export struct NoInterruptListen {

  @Builder header() {
    SymbolTitle({
      icon: $r('sys.symbol.play_circle_badge_music_note'),
      gradientColor: [0xa9def5, 0x7f86cc],
    })
  }

  @Builder footer() {
    Column() {


    }.height('30%').justifyContent(FlexAlign.Start)
  }

  build() {
    ImageTitleWelcomeTemplate({
      title: '无干扰，纯净听歌',
      subtitle: '极简 UX 设计，只保留必要的控制，多余元素自动隐藏，点击即可呼出。一切设计，都是为了纯净聆听。',
      customImage: this.header,
      footer: () => {
        this.footer()
      }
    })
  }
}