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

  @Local showPhone: boolean = false
  interval?: number

  aboutToAppear(): void {
    this.interval = setInterval(() => {
      this.showPhone = !this.showPhone
    }, 2000)
  }
  aboutToDisappear(): void {
    clearInterval(this.interval)
  }

  @Builder footer() {
    Scroll() {
      Row() {
        Row({space: 12}) {
          SimulatedPhone({
            showMusicPlayer: this.showPhone
          })
          SimulatedFoldable({
            showMusicPlayer: !this.showPhone
          })
        }
        .scale(ResponsiveUtil.chooseByWidth<ScaleOptions | undefined>([{x: 0.6, y: 0.6}, undefined]))
        .opacity(0.7)
      }.width(ResponsiveUtil.chooseByWidth<Length | undefined>([420, undefined]))
      .justifyContent(FlexAlign.Center)
    }.scrollable(ScrollDirection.Horizontal)
    .fadingEdge(true, {
      fadingEdgeLength: LengthMetrics.percent(10)
    })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring,{
      alwaysEnabled: false
    })

  }

  build() {
    ImageTitleWelcomeTemplate({
      title: '应用接续，音乐流转',
      subtitle: '基于 HarmonyOS 应用接续功能，音乐随时随你走。无缝切换，音乐从不间断；你的聆听，自然流动。',
      customImage: this.header,
      footer: () => {
        this.footer()
      }
    })
  }
}


@ComponentV2
struct SimulatedPhone {
  @Param showMusicPlayer: boolean = false

  // 桌面应用图标网格 (6x4)
  @Builder desktopGrid() {
    Column({space: 12}) {
      // 应用图标网格
      Column({space: 12}) {
        ForEach([0, 1, 2, 3, 4, 5], (rowIndex: number) => {
          Row({space: 12}) {
            ForEach([0, 1, 2, 3], (colIndex: number) => {
              // 应用图标
              Column()
                .width(24)
                .height(24)
                .backgroundColor('#40FFFFFF')
                .borderRadius(6)
            })
          }
        })
      }

      // Dock栏
      Row({space: 12}) {
        ForEach([0, 1, 2, 3], (index: number) => {
          Column()
            .width(24)
            .height(24)
            .backgroundColor('#60FFFFFF')
            .borderRadius(7)
        })
        Column()
          .width(24)
          .height(24)
          .backgroundColor('#E47546')
          .borderRadius(6)
      }
      .justifyContent(FlexAlign.Center)
      .padding({top: 16})
      .margin({top: 20})
    }.justifyContent(FlexAlign.SpaceBetween)
    .padding(16)
    .height('100%')
    .transition(TransitionEffect.asymmetric(TransitionEffect.OPACITY.animation({duration: 500, delay: 150}), undefined))
  }

  build() {
    Column() {
      if (this.showMusicPlayer) {
        SimulatedMusicPlayer().borderRadius(12)
          .transition(TransitionEffect.OPACITY.animation({duration: 300, curve: Curve.EaseInOut}).combine(TransitionEffect.scale({
            x: 0.1, y: 0.1
          }).animation({duration: 500,curve: Curve.ExtremeDeceleration})))
      } else {
        this.desktopGrid()
      }
    }
    .width(200)
    .height(300)
    .backgroundColor('#661A1A1A')
    .borderRadius(16)
    .clip(true)
    .border({
      width: 2,
      color: '#33000000'
    })
    .animation({
      duration: 400,
      curve: Curve.EaseInOut
    })
  }
}

@ComponentV2
struct SimulatedFoldable {
  @Param showMusicPlayer: boolean = false

  // 桌面应用图标网格 (6x8)
  @Builder desktopGrid() {
    Column() {
      Row() {
        // 左侧屏幕
        Column({space: 12}) {
          // 应用图标网格 (左侧)
          Column({space: 8}) {
            ForEach([0, 1, 2, 3, 4, 5], (rowIndex: number) => {
              Row({space: 12}) {
                ForEach([0, 1, 2, 3], (colIndex: number) => {
                  Column()
                    .width(25)
                    .height(25)
                    .backgroundColor('#40FFFFFF')
                    .borderRadius(5)
                })
              }
            })
          }
        }
        .padding(12)

        // 右侧屏幕
        Column({space: 12}) {
          // 应用图标网格 (右侧)
          Column({space: 8}) {
            ForEach([0, 1, 2, 3, 4, 5], (rowIndex: number) => {
              Row({space: 12}) {
                ForEach([0, 1, 2, 3], (colIndex: number) => {
                  Column()
                    .width(25)
                    .height(25)
                    .backgroundColor('#40FFFFFF')
                    .borderRadius(5)
                })
              }
            })
          }
        }
        .padding(12)
      }.justifyContent(FlexAlign.Center)
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')

      // 左侧Dock栏
      Row({space: 8}) {
        ForEach([0, 1, 2, 3, 4, 5], (index: number) => {
          Column()
            .width(24)
            .height(24)
            .backgroundColor('#60FFFFFF')
            .borderRadius(6)
        })
        Column()
          .width(24)
          .height(24)
          .backgroundColor('#E47546')
          .borderRadius(6)
      }
      .justifyContent(FlexAlign.Center)
      .margin({top: 12})
    }.width('100%')

    .transition(TransitionEffect.asymmetric(TransitionEffect.OPACITY.animation({duration: 500, delay: 150}), undefined))
  }

  build() {
    Row() {
      if (this.showMusicPlayer) {
        Row() {
          SimulatedMusicPlayer()
          SimulatedLyricArea()
        }.borderRadius(12)
          .transition(TransitionEffect.OPACITY.animation({duration: 300, curve: Curve.EaseInOut}).combine(TransitionEffect.scale({
            x: 0.1, y: 0.1
          }).animation({duration: 500,curve: Curve.ExtremeDeceleration})))
      } else {
        this.desktopGrid()
      }
    }
    .width(400)
    .height(300)
    .backgroundColor('#661A1A1A')
    .borderRadius(12)
    .clip(true)
    .border({
      width: 2,
      color: '#33000000'
    })
    .animation({
      duration: 400,
      curve: Curve.EaseInOut
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
          // 首页按钮 - 点击可返回桌面
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
