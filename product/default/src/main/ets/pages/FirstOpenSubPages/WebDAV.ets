import { LightUpIconTextButton, LightUpRoundedButton, UIComponentUtils, LightUpDefaultConfig } from "@handwer/ui_components";
import { ImageTitleWelcomeTemplate, SymbolTitle } from "./CommonTemplate";
import { LengthMetrics } from "@kit.ArkUI";
import { ResponsiveUtil } from "@handwer/base";

@ComponentV2
export struct WebDAV {

  @Builder header() {
    SymbolTitle({
      icon: $r('sys.symbol.music_note_icolud'),
      gradientColor: [0x8e2de2, 0x4a00e0],
    })
  }

  @Builder footer() {
    Column() {


    }.height('30%').justifyContent(FlexAlign.Start)
  }

  build() {
    ImageTitleWelcomeTemplate({
      title: $r('app.string.first_open_page_private_cloud_music_player'),
      subtitle: $r('app.string.first_open_page_private_cloud_desc'),
      customImage: this.header,
      footer: () => {
        this.footer()
      }
    })
  }
}