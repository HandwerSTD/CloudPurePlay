import { LightUpIconTextButton, LightUpRoundedButton, UIComponentUtils, LightUpDefaultConfig } from "@handwer/ui_components";
import { ImageTitleWelcomeTemplate, SymbolTitle } from "./CommonTemplate";
import { LengthMetrics } from "@kit.ArkUI";
import { ResponsiveUtil } from "@handwer/base";

@ComponentV2
export struct NoInterruptListen {

  @Builder header() {
    SymbolTitle({
      icon: $r('sys.symbol.play_circle_badge_music_note'),
      gradientColor: [0xfba6b9, 0x3d46e7],
    })
  }

  @Builder footer() {
    Column() {
      // 展示模拟的播放器界面
      SimulatedMusicPlayer()
        .alignSelf(ItemAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
  }

  build() {
    ImageTitleWelcomeTemplate({
      title: '「不打扰」的纯净听歌',
      subtitle: '极简 UX 设计，只保留必要的控制，多余元素自动隐藏，点击即可呼出。一切设计，都是为了纯净聆听。',
      customImage: this.header,
      footer: () => {
        this.footer()
      }
    })
  }
}

@ComponentV2
struct SimulatedMusicPlayer {
  @Local isPlaying: boolean = true
  @Local showProgress: boolean = false
  private progressTimeoutHandler?: number

  // 模拟显示进度条的方法
  private showProgressBar() {
    const showProgressBarTime = 3000 // 3秒

    if (this.progressTimeoutHandler) {
      clearTimeout(this.progressTimeoutHandler)
      this.progressTimeoutHandler = undefined
    }

    if (!this.showProgress) {
      // 显示进度条
      this.showProgress = true
      this.progressTimeoutHandler = setTimeout(() => {
        this.showProgress = false
      }, showProgressBarTime)
    } else {
      // 如果已经显示，重新计时
      this.progressTimeoutHandler = setTimeout(() => {
        this.showProgress = false
      }, showProgressBarTime)
    }
  }

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
            .backgroundColor('#4DFFFFFF')
            .borderRadius(12)
          
          // 设置按钮
          Column()
            .width(24)
            .height(24)
            .backgroundColor('#4DFFFFFF')
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
          .backgroundColor('#80FFFFFF')
          .borderRadius(12)
          .shadow({
            radius: 8,
            color: '#33000000',
            offsetY: 4
          })
          .onClick(() => {
            this.showProgressBar()
          })

        Row() {
          // 歌曲信息区域 (两行文字的模拟)
          Column({ space: 4 }) {
            // 歌曲名
            Column()
              .width(100)
              .height(6)
              .backgroundColor('#CCFFFFFF')
              .borderRadius(3)

            // 艺术家名
            Column()
              .width(80)
              .height(4)
              .backgroundColor('#99FFFFFF')
              .borderRadius(2)
          }.alignItems(HorizontalAlign.Start)
          .margin({ top: 16 })

          // 底部控制按钮区域
          Column() {
            // 模拟喜欢按钮
            Column()
              .width(20)
              .height(20)
              .backgroundColor('#4DFFFFFF')
              .borderRadius(10)
          }
          .alignSelf(ItemAlign.End)
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({left: 16, right: 16})
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({bottom: 12})


      // 进度条区域
      Column() {
        // 进度条
        Row() {
          Column()
            .height(2)
            .layoutWeight(0.4)
            .backgroundColor('#CCFFFFFF')
            .borderRadius(1)

          Column()
            .height(2)
            .layoutWeight(0.6)
            .backgroundColor('#4DFFFFFF')
            .borderRadius(1)
        }
        .width('80%')

        // 时间显示 (两个小矩形模拟)
        Row() {
          Column()
            .width(20)
            .height(3)
            .backgroundColor('#99FFFFFF')
            .borderRadius(1.5)

          Blank()

          Column()
            .width(20)
            .height(3)
            .backgroundColor('#99FFFFFF')
            .borderRadius(1.5)
        }
        .width('80%')
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 16 })
      .height(this.showProgress ? undefined : 0)
      .opacity(this.showProgress ? 0.7 : 0)
      .animation({
        duration: 300,
        curve: Curve.EaseInOut
      })

      // 播放控制区域
      Row({ space: 20 }) {
        // 上一首按钮
        Column()
          .width(28)
          .height(28)
          .backgroundColor('#CCFFFFFF')
          .borderRadius(14)
        
        // 播放/暂停按钮 (大一些)
        Column()
          .width(40)
          .height(40)
          .backgroundColor('#CCFFFFFF')
          .borderRadius(20)
          .border({
            width: this.isPlaying ? 0 : 2,
            color: '#CCFFFFFF'
          })
          .backgroundColor(this.isPlaying ? '#66FFFFFF' : Color.Transparent)
          .onClick(() => {
            this.isPlaying = !this.isPlaying
          })
        
        // 下一首按钮
        Column()
          .width(28)
          .height(28)
          .backgroundColor('#CCFFFFFF')
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
    .borderRadius(16)
    .animation({ 
      duration: 300, 
      curve: Curve.EaseInOut 
    })
  }
}