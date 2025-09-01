import { LightUpIconTextButton, LightUpRoundedButton, UIComponentUtils, LightUpDefaultConfig } from "@handwer/ui_components";
import { ImageTitleWelcomeTemplate, SymbolTitle } from "./CommonTemplate";
import { LengthMetrics } from "@kit.ArkUI";
import { ResponsiveUtil } from "@handwer/base";
import { hdsEffect } from "@kit.UIDesignKit";

@ComponentV2
struct OverlayClickSymbol {
  build() {
    SymbolGlyph($r('sys.symbol.hand_point_up_tap_fill'))
      .fontColor([$r('app.color.SkyBlue')])
      .fontSize(30)
      .rotate({
        angle: -45
      })
      .symbolShadow({
        radius: 12,
        color: '#aa000000'
      })
  }
}

@ComponentV2
export struct NoInterruptListen {

  get flexParam(): FlexOptions {
    return {direction: ResponsiveUtil.chooseByWidth([FlexDirection.ColumnReverse, FlexDirection.Row]), justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center, space: {main: LengthMetrics.vp(ResponsiveUtil.chooseByWidth([0, 24]))}}
  }
  get flexPadding(): Padding {
    return ResponsiveUtil.chooseByWidth<Padding>([{left: 12, right: 12}, {left:24, right: 24}])
  }

  @Builder header() {
    SymbolTitle({
      icon: $r('sys.symbol.play_circle_badge_music_note'),
      gradientColor: [0xfba6b9, 0x3d46e7],
    })
  }

  @Builder featureCard(symbol: Resource, msg: string) {
    Column() {
      SymbolTitle({
        icon: symbol,
        gradientColor: [0xe4b7d4, 0xbc97d4]
      }).padding({top: 24})
      Text(msg)
        .fontColor(Color.White)
        .padding({top: 24})
    }.layoutWeight(ResponsiveUtil.chooseByWidth([0, 1]))
  }
  @Builder PlayerUI() {
    Flex(this.flexParam) {
      SimulatedMusicPlayer_HideProgress()
      this.featureCard($r('sys.symbol.identify_song'), '隐藏式进度条，点击显示，自动隐藏，界面更清爽')
    }
    .height(ResponsiveUtil.chooseByWidth([540, 320]))
    .width('100%')
    .padding(this.flexPadding)
  }

  @Builder ShowExplore() {
    Flex(this.flexParam) {
      SimulatedMusicPlayer_ShowExplore()
      this.featureCard($r('sys.symbol.house'), '在播放器页面，点击󰀦进入探索页；在探索页点击底部封面，可返回播放器，一镜到底，尽显优雅')
    }
    .height(ResponsiveUtil.chooseByWidth([540, 320]))
    .width('100%')
    .padding(this.flexPadding)
  }

  @Builder PlayQueue() {
    Flex(this.flexParam) {
      SimulatedMusicPlayer_PlayQueue()
      this.featureCard($r('sys.symbol.list_bullet'), '点击歌曲信息打开播放队列，管理播放列表')
    }
    .height(ResponsiveUtil.chooseByWidth([540, 320]))
    .width('100%')
    .padding(this.flexPadding)
  }

  @Builder footer() {
    Row() {
      Swiper() {
        this.PlayerUI()
        this.ShowExplore()
        this.PlayQueue()
      }
      .autoPlay(true)
      .interval(8000)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.play_list_single_item_bg'))
    .borderRadius(24)
    .padding({bottom: 24, top: ResponsiveUtil.chooseByWidth([0, 24])})
    .visualEffect(new hdsEffect.HdsEffectBuilder().pointLight({
      illuminatedType: hdsEffect.PointLightIlluminatedType.CONTENT
    }).buildEffect())
  }

  build() {
    ImageTitleWelcomeTemplate({
      title: '「不打扰」的纯净听歌',
      subtitle: '极简 UX 设计，只保留必要的控制，多余元素自动隐藏，给你更清爽的听歌体验。一切设计，都是为了纯净聆听。',
      customImage: this.header,
      footer: () => {
        this.footer()
      }
    })
  }
}

@ComponentV2
struct SimulatedMusicPlayer_HideProgress {
  @Local isPlaying: boolean = true
  @Local showProgress: boolean = false
  private progressTimeoutHandler?: number

  // 模拟显示进度条的方法
  private showProgressBar() {
    const showProgressBarTime = 1500 // 3秒

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

  @Local anim_TapScale: boolean = false

  @Builder tap() {
    OverlayClickSymbol()
      .scale(this.anim_TapScale ? {x: 0.9, y: 0.9} : undefined)
      .animation({duration: 300})
      .translate({x: 80, y: 80})
  }

  animator() {
    this.anim_TapScale = true;
    setTimeout(() => {
      this.anim_TapScale = false;
      this.showProgressBar()
    }, 300)
  }

  interval?: number

  aboutToAppear(): void {
    this.interval = setInterval(() => {
      this.animator()
    }, 300+1500+ 1000)
  }

  aboutToDisappear(): void {
    clearInterval(this.interval)
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
          // .shadow({
          //   radius: 32,
          //   color: '#AAFFFFFF',
          //   offsetY: 4
          // })
          .onClick(() => {
            this.showProgressBar()
          })
          .overlay(this.tap)

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


      // 进度条区域
      Column() {
        // 进度条
        Row() {
          Column()
            .height(2)
            .layoutWeight(0.4)
            .backgroundColor('#DDFFFFFF')
            .borderRadius(1)

          Column()
            .height(2)
            .layoutWeight(0.6)
            .backgroundColor('#FFFFFF')
            .borderRadius(1)
        }
        .width('80%')

        // 时间显示 (两个小矩形模拟)
        Row() {
          Column()
            .width(20)
            .height(3)
            .backgroundColor('#FFFFFF')
            .borderRadius(1.5)
            .shadow({
              radius: 4,
              color: '#AAFFFFFF',
            })

          Blank()

          Column()
            .width(20)
            .height(3)
            .backgroundColor('#FFFFFF')
            .borderRadius(1.5)
            .shadow({
              radius: 4,
              color: '#AAFFFFFF',
            })
        }
        .width('80%')
        .margin({ top: 4 })
      }.brightness(1.3)
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
          .backgroundColor('#40FFFFFF') 
          .borderRadius(14)

        // 播放/暂停按钮 (大一些，可交互)
        Column()
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#40FFFFFF')

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
    .borderRadius(16)
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }
}


@ComponentV2
struct SimulatedMusicPlayer_ShowExplore {
  @Local showExplore: boolean = false
  @Local exploreOpacity: number = 0
  @Local anim_TapScale: boolean = false

  // 模拟展开/收起动画
  private toggleExplore() {
    this.showExplore = !this.showExplore
    this.exploreOpacity = this.showExplore ? 1 : 0
  }

  @Builder tap() {
    OverlayClickSymbol()
      .scale(this.anim_TapScale ? {x: 0.9, y: 0.9} : undefined)
      .animation({duration: 300})
      .translate({x: 10, y: 10})
  }

  animator() {
    this.anim_TapScale = true;
    setTimeout(() => {
      this.anim_TapScale = false;
      this.toggleExplore()
    }, 300)
  }

  interval?: number

  aboutToAppear(): void {
    this.interval = setInterval(() => {
      this.animator()
    }, 300+2000)
  }

  aboutToDisappear(): void {
    clearInterval(this.interval)
  }

  @Builder ExploreArea() {
    Column() {
      // 模拟Explore页面内容
      Column() {
        // 标题区域
        Row() {
          Column()
            .width(80)
            .height(4)
            .backgroundColor('#60FFFFFF') 
            .borderRadius(2)

          Blank()

          Column()
            .width(20)
            .height(20)
            .backgroundColor('#30FFFFFF') 
            .borderRadius(10)
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 内容网格
        Column({ space: 8 }) {
          // 第一行
          Row({ space: 8 }) {
            Column()
              .width(40)
              .height(40)
              .backgroundColor('#30FFFFFF') 
              .borderRadius(8)
            Column()
              .width(40)
              .height(40)
              .backgroundColor('#30FFFFFF') 
              .borderRadius(8)
            Column()
              .width(40)
              .height(40)
              .backgroundColor('#30FFFFFF') 
              .borderRadius(8)
          }

          // 第二行
          Row({ space: 8 }) {
            Column()
              .width(40)
              .height(40)
              .backgroundColor('#30FFFFFF') 
              .borderRadius(8)
            Column()
              .width(40)
              .height(40)
              .backgroundColor('#30FFFFFF') 
              .borderRadius(8)
            Column()
              .width(40)
              .height(40)
              .backgroundColor('#30FFFFFF') 
              .borderRadius(8)
          }
        }
      }
      .width('100%')
      .height(180)
      .padding(12)
      .backgroundColor('#1A000000')
      .borderRadius(12)
      .margin({ bottom: 8 })
    }.height(this.exploreOpacity === 0 ? 0 : undefined)
    .layoutWeight(this.exploreOpacity === 0 ? 0 : 1)
    .width('100%')
    .opacity(this.exploreOpacity)
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }

  @Builder NormalPlayerArea() {
    Column() {

      // 顶部区域 - 模拟操作按钮
      Row() {
        // 右侧按钮组
        Row({ space: 12 }) {
          Column()
            .width(24)
            .height(24)
            .backgroundColor('#30FFFFFF')
            .borderRadius(12)

          Column() {
            SymbolGlyph($r('sys.symbol.house'))
              .fontColor([Color.Black])
              .fontSize(14)
          }.justifyContent(FlexAlign.Center)
          .width(24)
          .height(24)
          .backgroundColor('#CCFFFFFF')
          .borderRadius(12)
          .shadow({
            radius: 32,
            color: '#AAFFFFFF',
            offsetY: 4
          })
          .onClick(() => {
            this.toggleExplore()
          })
          .overlay(this.tap)
        }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .height(40)
      .padding({ left: 16, right: 16 })
      // 中间内容区域
      Column({space: 12}) {
        // 专辑封面区域 (可交互 - 点击切换Explore)
        Column()
          .width(120)
          .height(120)
          .backgroundColor('#50FFFFFF') 
          .borderRadius(12)

        Row() {
          // 歌曲信息区域 (两行文字的模拟)
          Column({ space: 4 }) {
            // 歌曲名
            Column()
              .width(100)
              .height(6)
              .backgroundColor('#80FFFFFF') 
              .borderRadius(3)

            // 艺术家名
            Column()
              .width(80)
              .height(4)
              .backgroundColor('#60FFFFFF') 
              .borderRadius(2)
          }.alignItems(HorizontalAlign.Start)

          // 底部控制按钮区域 (可交互 - 首页按钮)
          Column() {
            // 首页按钮
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

        // 播放/暂停按钮 (大一些)
        Column()
          .width(40)
          .height(40)
          .backgroundColor('#40FFFFFF') 
          .borderRadius(20)

        // 下一首按钮
        Column()
          .width(28)
          .height(28)
          .backgroundColor('#40FFFFFF') 
          .borderRadius(14)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .layoutWeight(this.showExplore ? 0 : 1)
    .opacity(this.showExplore ? 0 : 1)
    .height(this.showExplore ? 0 : undefined)
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }

  @Builder BottomPlayerBar() {
    Row({ space: 12 }) {
      // 小封面 (可交互 - 点击收起Explore)
      Column()
        .width(40)
        .height(40)
        .backgroundColor('#AAFFFFFF')
        .borderRadius(8)
        .shadow({
          radius: 32,
          color: '#AAFFFFFF',
          offsetY: 4
        })
        .onClick(() => {
          this.toggleExplore()
        })
        .overlay(this.tap)

      // 歌曲信息
      Column({ space: 2 }) {
        Column()
          .width(60)
          .height(4)
          .backgroundColor('#80FFFFFF') 
          .borderRadius(2)
        Column()
          .width(40)
          .height(3)
          .backgroundColor('#60FFFFFF') 
          .borderRadius(1.5)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 播放按钮
      Column()
        .width(32)
        .height(32)
        .backgroundColor('#40FFFFFF') // 降低高亮亮度
        .borderRadius(16)
    }
    .width('100%')
    .height(56)
    .padding({ left: 12, right: 12 })
    .opacity(this.showExplore ? 1 : 0)
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }

  build() {
    Column() {

      // Explore区域
      this.ExploreArea()

      // 正常播放器区域
      this.NormalPlayerArea()

      // 底部播放栏
      this.BottomPlayerBar()
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


@ComponentV2
struct SimulatedMusicPlayer_PlayQueue {
  @Local showPlayQueue: boolean = false
  @Local playQueueOpacity: number = 0
  @Local anim_TapScale: boolean = false

  // 切换播放队列显示状态
  private togglePlayQueue() {
    this.showPlayQueue = !this.showPlayQueue
    this.playQueueOpacity = this.showPlayQueue ? 1 : 0
  }

  @Builder tap() {
    OverlayClickSymbol()
      .scale(this.anim_TapScale ? {x: 0.9, y: 0.9} : undefined)
      .animation({duration: 300})
      .translate({x: 40, y: 20})
  }

  animator() {
    this.anim_TapScale = true;
    setTimeout(() => {
      this.anim_TapScale = false;
      this.togglePlayQueue()
    }, 300)
  }

  interval?: number

  aboutToAppear(): void {
    this.interval = setInterval(() => {
      this.animator()
    }, 300+2000)
  }

  aboutToDisappear(): void {
    clearInterval(this.interval)
  }

  @Builder PlayQueueSheet() {
    Column() {
      // 顶部把手
      Column()
        .width(32)
        .height(4)
        .backgroundColor('#30FFFFFF') 
        .borderRadius(2)
        .margin({ top: 8, bottom: 16 })

      // 标题
      Row() {
        Text('播放队列')
          .fontSize(14)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)

        Blank()

        // 关闭按钮 (可交互)
        Column()
          .width(20)
          .height(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
          // 高亮可交互区域
          .border({
            width: 1,
            color: '#80FFFFFF'
          })
          .onClick(() => {
            this.togglePlayQueue()
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 队列列表
      Column({ space: 8 }) {
        // 当前播放的歌曲
        Row({ space: 8 }) {
          Column()
            .width(32)
            .height(32)
            .backgroundColor('#50FFFFFF') 
            .borderRadius(4)

          Column({ space: 2 }) {
            Column()
              .width(80)
              .height(4)
              .backgroundColor('#80FFFFFF') 
              .borderRadius(2)
            Column()
              .width(60)
              .height(3)
              .backgroundColor('#60FFFFFF') 
              .borderRadius(1.5)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          // 播放指示
          Column()
            .width(4)
            .height(16)
            .backgroundColor('#66FF6B')
            .borderRadius(2)
        }
        .width('100%')
        .padding({ left: 8, right: 8, top: 6, bottom: 6 })
        .backgroundColor('#1AFFFFFF')
        .borderRadius(8)

        // 队列中的其他歌曲
        ForEach([1, 2, 3], (index: number) => {
          Row({ space: 8 }) {
            Column()
              .width(32)
              .height(32)
              .backgroundColor('#30FFFFFF') 
              .borderRadius(4)

            Column({ space: 2 }) {
              Column()
                .width(70 + index * 5)
                .height(4)
                .backgroundColor('#60FFFFFF') 
                .borderRadius(2)
              Column()
                .width(50 + index * 3)
                .height(3)
                .backgroundColor('#40FFFFFF') 
                .borderRadius(1.5)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Column()
              .width(16)
              .height(16)
              .backgroundColor('#30FFFFFF') 
              .borderRadius(8)
          }
          .width('100%')
          .padding({ left: 8, right: 8, top: 6, bottom: 6 })
        })
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(200)
    .padding(12)
    .backgroundColor('#CC000000')
    .backgroundBlurStyle(BlurStyle.BACKGROUND_REGULAR)
    .borderRadius({ topLeft: 16, topRight: 16 })
    .opacity(this.playQueueOpacity)
    .translate({ y: this.showPlayQueue ? 0 : 150 })
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 主播放器界面
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
            .backgroundColor('#50FFFFFF') 
            .borderRadius(12)
            .shadow({
              radius: 8,
              color: '#33000000',
              offsetY: 4
            })

          Row() {
            // 歌曲信息区域 (两行文字的模拟) - 点击打开播放队列 (可交互)
            Column({ space: 4 }) {
              // 歌曲名
              Column()
                .width(100)
                .height(6)
                .backgroundColor('#AAFFFFFF')
                .borderRadius(3)

              // 艺术家名
              Column()
                .width(80)
                .height(4)
                .backgroundColor('#AAFFFFFF')
                .borderRadius(2)
            }
            .alignItems(HorizontalAlign.Start)
            // 高亮可交互区域
            .border({
              width: 1,
              color: '#AAFFFFFF'
            })
            .shadow({
              radius: 32,
              color: '#AAFFFFFF',
              offsetY: 4
            })
            .borderRadius(4)
            .padding(4)
            .onClick(() => {
              this.togglePlayQueue()
            })
            .overlay(this.tap)

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

          // 播放/暂停按钮 (大一些)
          Column()
            .width(40)
            .height(40)
            .backgroundColor('#40FFFFFF') 
            .borderRadius(20)

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
      .borderRadius(16)

      // 播放队列半模态
      this.PlayQueueSheet()

      // 背景遮罩
      if (this.showPlayQueue) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#33000000')
          .onClick(() => {
            this.togglePlayQueue()
          })
          .opacity(this.playQueueOpacity * 0.5)
          .animation({
            duration: 300,
            curve: Curve.EaseInOut
          })
      }
    }
    .width(200)
    .height(300)
    .clip(true)
    .borderRadius(16)
  }
}