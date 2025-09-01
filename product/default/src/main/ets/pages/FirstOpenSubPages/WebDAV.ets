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
      title: '私有云音乐播放器',
      subtitle: '连接你的私有云，直达你的音乐库。无需依赖流媒体，所有歌曲，始终掌握在你手中。\n\n现支持 Navidrome 协议服务器。\n\n在新手引导结束后，将会帮助你设置音乐源。',
      customImage: this.header,
      footer: () => {
        this.footer()
      }
    })
  }
}