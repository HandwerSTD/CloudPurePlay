import { LightUpIconTextButton, LightUpRoundedButton, UIComponentUtils, LightUpDefaultConfig } from "@handwer/ui_components";
import { ImageTitleWelcomeTemplate, SymbolTitle } from "./CommonTemplate";
import { LengthMetrics } from "@kit.ArkUI";
import { ResponsiveUtil } from "@handwer/base";

@ComponentV2
export struct MissionContinue {

  @Builder header() {
    SymbolTitle({
      icon: $r('sys.symbol.Interconnection_ic_multiscreen_collaboration'),
      gradientColor: [0xfc00ff, 0x00dbde],
    })
  }

  @Builder footer() {
    Column() {


    }.height('30%').justifyContent(FlexAlign.Start)
  }

  build() {
    ImageTitleWelcomeTemplate({
      title: '应用接续，音乐流转',
      subtitle: '基于 HarmonyOS 应用接续功能，音乐随时随你走。在手机开始，在平板延续。无缝切换，音乐从不间断。你的聆听，自然流动。',
      customImage: this.header,
      footer: () => {
        this.footer()
      }
    })
  }
}