import { promptAction, router } from '@kit.ArkUI';
import { OpenWelcome } from './OpenWelcome';
import { FinalWelcome } from './FinalWelcome';
import { GlobalStore } from '@handwer/base';

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

  build() {
    Row() {
      Column() {
        Swiper(this.controller) {
          OpenWelcome({
            setResult: (val) => { this.agreed = val }
          })

          FinalWelcome({
            onFinish: () => {
              this.jumpToApp()
            }
          })
        }.width('100%')
        .onChange((index) => {
          this.nowIndex = index
        })
        .disableSwipe(!this.agreed) // 不同意不让进
        .loop(false)
        .indicator(false)
        .layoutWeight(1)
        MyStepper({
          nowIndex: this.nowIndex,
          configuration: this.stepperConfig
        })
      }
      .height('100%')
    }
    .width('100%')
    .padding({ top: this.st.wd.top, bottom: this.st.wd.bottom })
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