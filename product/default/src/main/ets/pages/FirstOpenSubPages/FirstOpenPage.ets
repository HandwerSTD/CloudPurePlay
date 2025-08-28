import { promptAction, router } from '@kit.ArkUI';
import { OpenWelcome } from './OpenWelcome';
import { FinalWelcome } from './FinalWelcome';
import { GlobalStore } from '@handwer/base';
import { hdsEffect } from '@kit.UIDesignKit';
import { LightUp } from './LightUp';
import { WebDAV } from './WebDAV';
import { NoInterruptListen } from './NoInterruptListen';
import { PersonalFM } from './PersonalFM';
import { MissionContinue } from './MissionContinue';

@Entry
@ComponentV2
struct FirstOpenPage {
  st = GlobalStore
  @Local agreed: boolean = false

  controller: SwiperController = new SwiperController()
  @Local nowIndex: number = 0
  stepperConfig: MyStepperConfig[] = [{
    // OpenWelcome
    nextLabel: $r('sys.string.stepper_next'),
    onNext: () => {
      if (!this.agreed) {
        promptAction.showToast({
          message: '请阅读并同意《关于表情快传隐私的声明》'
        })
      } else {
        this.controller.showNext()
      }
    }
  },{
    // LightUp
    previousLabel: $r('sys.string.stepper_back'),
    nextLabel: $r('sys.string.stepper_next'),
    onPrevious: () => {
      this.controller.showPrevious()
    },
    onNext: () => {
      this.controller.showNext()
    }
  },{
    // WebDAV
    previousLabel: $r('sys.string.stepper_back'),
    nextLabel: $r('sys.string.stepper_next'),
    onPrevious: () => {
      this.controller.showPrevious()
    },
    onNext: () => {
      this.controller.showNext()
    }
  },{
    // NoInterrupt
    previousLabel: $r('sys.string.stepper_back'),
    nextLabel: $r('sys.string.stepper_next'),
    onPrevious: () => {
      this.controller.showPrevious()
    },
    onNext: () => {
      this.controller.showNext()
    }
  },{
    // PersonalFM
    previousLabel: $r('sys.string.stepper_back'),
    nextLabel: $r('sys.string.stepper_next'),
    onPrevious: () => {
      this.controller.showPrevious()
    },
    onNext: () => {
      this.controller.showNext()
    }
  },{
    // MissionContinue
    previousLabel: $r('sys.string.stepper_back'),
    nextLabel: $r('sys.string.stepper_next'),
    onPrevious: () => {
      this.controller.showPrevious()
    },
    onNext: () => {
      this.controller.showNext()
    }
  },{
    // FinalWelcome
    previousLabel: $r('sys.string.stepper_back'),
    nextLabel: $r('sys.string.general_start'),
    onNext: () => {
      this.jumpToApp()
    },
    onPrevious: () => {
      this.controller.showPrevious()
    }
  }]

  private jumpToApp() {
    router.replaceUrl({
      url: 'pages/Index'
    })
  }

  @Builder BackgroundFlow() {

    Column() {
      if (GlobalStore.isDarkMode) {
        Column().width('100%').height('100%')
          .visualEffect(new hdsEffect.HdsEffectBuilder()
            .shaderEffect({
              effectType: hdsEffect.EffectType.UV_BACKGROUND_FLOW_LIGHT,
              params: {
                colorSource: [Color.Black, Color.Blue, Color.Pink],
              },
              animation: {
                duration: 5000,
                autoPlay: true,
                iterations: -1
              }
            })
            .buildEffect())
          .transition(TransitionEffect.OPACITY.animation({duration: 1000}))
      } else {
        Column().width('100%').height('100%')
          .visualEffect(new hdsEffect.HdsEffectBuilder()
            .shaderEffect({
              effectType: hdsEffect.EffectType.UV_BACKGROUND_FLOW_LIGHT,
              // controller: this.controller,
              animation: {
                duration: 5000,
                autoPlay: true,
                iterations: -1
              }
            })
            .buildEffect())
          .transition(TransitionEffect.OPACITY.animation({duration: 1000}))
      }
    }.width('100%').height('100%')
  }

  @Local showFlow: boolean = false

  build() {
    Row() {
      Stack() {
        if (this.showFlow) {
          this.BackgroundFlow()
        }
        Stack({alignContent: Alignment.Bottom}) {
          Swiper(this.controller) {
            OpenWelcome({
              setResult: (val) => { this.agreed = val },
              showedFlow: this.showFlow
            })
            LightUp()
            WebDAV()
            NoInterruptListen()
            PersonalFM()
            MissionContinue()
            FinalWelcome({
              onFinish: () => {
                this.jumpToApp()
              }
            }).clip(false)
          }.width('100%')
          .onChange((index) => {
            this.nowIndex = index
            if (index === 1) this.showFlow = true
          })
          .disableSwipe(!this.agreed) // 不同意不让进
          .loop(false)
          .indicator(false)
          .layoutWeight(1)
          .clip(false)
          MyStepper({
            nowIndex: this.nowIndex,
            configuration: this.stepperConfig
          }).clip(false)
        }
        .padding({ top: this.st.wd.top, bottom: this.st.wd.bottom })
        .height('100%')
      }
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

interface MyStepperConfig {
  nextLabel: ResourceStr
  previousLabel?: ResourceStr
  onNext: () => void
  onPrevious?: () => void
}

@ComponentV2
struct MyStepper {
  @Param @Require configuration: MyStepperConfig[]
  @Param @Require nowIndex: number

  @Builder leftBuilder() {
    Row() {
      if (this.configuration[this.nowIndex].previousLabel) {
        Row({space: 8}) {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .fontColor([$r('sys.color.font_primary')])
          Text(this.configuration[this.nowIndex].previousLabel)
        }.alignItems(VerticalAlign.Center)
        .height(24)
        .onClick(() => {
          this.configuration[this.nowIndex].onPrevious?.()
        })
      }
    }
  }
  @Builder rightBuilder() {
    Row({space: 8}) {
      Text(this.configuration[this.nowIndex].nextLabel)
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor([$r('sys.color.font_primary')])
    }.alignItems(VerticalAlign.Center)
    .height(24)
    .onClick(() => {
      this.configuration[this.nowIndex].onNext()
    })
    .transition(TransitionEffect.OPACITY)
  }

  build() {
    Row() {
      this.leftBuilder()
      this.rightBuilder()
    }.width('100%')
    .height(60)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(24)
  }
}