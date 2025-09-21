import { GlobalStore, SCPref, Settings } from "@handwer/base"
import { BgFlowController } from "@handwer/ui_components"
import { hdsEffect } from "@kit.UIDesignKit"

@ComponentV2
export struct BackgroundFlow {
  controller?: BgFlowController
  gs = GlobalStore

  aboutToAppear(): void {
    this.controller = BgFlowController.getInstance()
  }

  @Monitor('gs.isDarkMode')
  onDarkModeSwitch() {
    if (this.controller?.onDefaultColor) {
      this.controller.changeColorToDefault()
    }
  }

  build() {
    Column() {
      ForEach([0, 1], (idx: number) => {
        if (this.controller?.switch === idx) {
          Column().width('100%').height('100%')
            .visualEffect(new hdsEffect.HdsEffectBuilder()
              .shaderEffect({
                effectType: hdsEffect.EffectType.UV_BACKGROUND_FLOW_LIGHT,
                controller: this.controller?.controller[idx],
                params: {
                  colorSource: [Color.Black, Color.Blue, Color.Pink]
                },
                // animation: {
                //   duration: 5000,
                //   iterations: -1,
                //   autoPlay: true
                // }
              })
              .buildEffect())
            .transition(TransitionEffect.OPACITY.animation({duration: 2000}))
            .flowStyle()

        }
      })
    }.width('100%').height('100%')
    .onAppear(() => {
      if (Settings.get<boolean>(SCPref.dynamicBackgroundStreaming)) {
        this.controller!.play()
      }
    })
  }
}

@Extend(Column) function flowStyle() {
  .opacity(GlobalStore.isDarkMode && GlobalStore.pref.bgFlowColorStrat !== 0 ? 0.5 : 1)
  .animation({duration: 2000})
}