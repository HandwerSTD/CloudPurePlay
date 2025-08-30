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

  build() {
    ImageTitleWelcomeTemplate({
      title: '应用接续，音乐流转',
      subtitle: '基于 HarmonyOS 应用接续功能，音乐随时随你走。在手机开始，在平板延续。无缝切换，音乐从不间断。你的聆听，自然流动。',
      customImage: this.header,
      footer: () => {

      }
    })
  }
}


@ComponentV2
struct SimulatedPhone {
  build() {
    Column() {
      SimulatedMusicPlayer()
    }.borderRadius(16)
    .clip(true)
    .border({
      width: 2,
      color: '#99000000'
    })
  }
}
@ComponentV2
struct SimulatedFoldable {
  build() {
    Row() {
      SimulatedMusicPlayer()
      SimulatedLyricArea()
    }.borderRadius(12).clip(true)
    .border({
      width: 2,
      color: '#99000000'
    })
  }
}

@ComponentV2
struct SimulatedMusicPlayer {

  build() {
    Column() {
      // 顶部区域 - 模拟操作按钮
      Row() {
        // 右侧按钮组
        Row({ space: 12 }) {
          // 首页按钮
          Column()
            .width(24)
            .height(24)
            .backgroundColor('#30FFFFFF')
            .borderRadius(12)

          // 设置按钮
          Column()
            .width(24)
            .height(24)
            .backgroundColor('#30FFFFFF')
            .borderRadius(12)
        }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .height(40)
      .padding({ left: 16, right: 16 })

      // 中间内容区域
      Column({space: 12}) {
        // 专辑封面区域
        Column()
          .width(120)
          .height(120)
          .backgroundColor('#88FFFFFF')
          .borderRadius(12)

        Row() {
          // 歌曲信息区域 (两行文字的模拟)
          Column({ space: 4 }) {
            // 歌曲名
            Column()
              .width(100)
              .height(6)
              .backgroundColor('#40FFFFFF')
              .borderRadius(3)

            // 艺术家名
            Column()
              .width(80)
              .height(4)
              .backgroundColor('#40FFFFFF')
              .borderRadius(2)
          }.alignItems(HorizontalAlign.Start)
          .margin({ top: 16 })

          // 底部控制按钮区域
          Column() {
            // 模拟喜欢按钮
            Column()
              .width(20)
              .height(20)
              .backgroundColor('#30FFFFFF')
              .borderRadius(10)
          }
          .alignSelf(ItemAlign.End)
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({left: 16, right: 16})
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({bottom: 12})

      // 播放控制区域
      Row({ space: 20 }) {
        // 上一首按钮
        Column()
          .width(28)
          .height(28)
          .backgroundColor('#40FFFFFF')
          .borderRadius(14)

        // 播放/暂停按钮 (大一些，可交互)
        Column()
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#77FFFFFF')

        // 下一首按钮
        Column()
          .width(28)
          .height(28)
          .backgroundColor('#40FFFFFF')
          .borderRadius(14)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .margin({ bottom: 20 })
    }
    .width(200)
    .height(300)
    .padding(12)
    .backgroundColor('#331A1A1A')
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }
}


@ComponentV2
struct SimulatedLyricArea {
  build() {
    Column({space: 12}) {
      // 歌词标题区域
      Column()
        .width(60)
        .height(6)
        .backgroundColor('#60FFFFFF')
        .borderRadius(3)
        .alignSelf(ItemAlign.Center)
        .margin({bottom: 8})

      // 模拟歌词行
      Column({space: 8}) {
        // 第一行歌词 - 当前行，高亮显示
        Column()
          .width(150)
          .height(6)
          .backgroundColor('#88FFFFFF')
          .borderRadius(3)

        // 第二行歌词 - 普通显示
        Column()
          .width(120)
          .height(5)
          .backgroundColor('#40FFFFFF')
          .borderRadius(2.5)

        // 第三行歌词 - 普通显示
        Column()
          .width(140)
          .height(5)
          .backgroundColor('#40FFFFFF')
          .borderRadius(2.5)

        // 第四行歌词 - 普通显示
        Column()
          .width(110)
          .height(5)
          .backgroundColor('#40FFFFFF')
          .borderRadius(2.5)

        // 第五行歌词 - 普通显示
        Column()
          .width(130)
          .height(5)
          .backgroundColor('#40FFFFFF')
          .borderRadius(2.5)
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(HorizontalAlign.Center)
      .layoutWeight(1)
    }
    .width(200)
    .height(300)
    .padding(16)
    .backgroundColor('#331A1A1A')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }
}
