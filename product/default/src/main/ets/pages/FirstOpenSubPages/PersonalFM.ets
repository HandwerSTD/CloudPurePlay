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

  @Builder footer() {
    Column() {


    }.height('30%').justifyContent(FlexAlign.Start)
  }

  build() {
    ImageTitleWelcomeTemplate({
      title: '开屏即听，无限推荐',
      subtitle: '启动应用即播放，少一步繁琐，多一点音乐。私人 FM 模式，无限推荐歌曲播放，始终新鲜。',
      customImage: this.header,
      footer: () => {
        this.footer()
      }
    })
  }
}