import { GlobalStore } from "@handwer/base";
import { hdsEffect } from "@kit.UIDesignKit"

const LightColor: ResourceColor[] = ['#BD74DB', '#9CB6DD', '#C2A87B', '#7C87D2'];
const DarkColor: ResourceColor[] = [Color.Black, Color.Pink, Color.Blue]

export enum FlowPlayState {
  STOP,
  PLAY,
  PAUSED
}

@ObservedV2
export class BgFlowController {
  static instance?: BgFlowController
  controller: hdsEffect.ShaderEffectController[] = [new hdsEffect.ShaderEffectController(), new hdsEffect.ShaderEffectController()]
  private constructor() {}

  @Trace switch: number = 0 // 当前显示的 bg

  flowPlayState: FlowPlayState = FlowPlayState.STOP
  onDefaultColor: boolean = true

  static getInstance() {
    if (!BgFlowController.instance) {
      BgFlowController.instance = new BgFlowController()
    }
    return BgFlowController.instance!
  }

  get currentSwitch() {
    return this.switch
  }
  get nextSwitch() {
    return (this.switch + 1) % 2;
  }
  switchToNext() {
    this.switch = this.nextSwitch
  }
  changeColor(colors: ResourceColor[]) {
    if (GlobalStore.pref.bgFlowColorStrat === 0) {
      this.changeColorToDefault()
    } else {
      this._changeColor(colors)
    }
  }
  private _changeColor(colors: ResourceColor[]) {
    this.onDefaultColor = false;
    this.switchToNext()
    setTimeout(() => {
      this.controller[this.currentSwitch].setEffectParams({
        colorSource: colors
      })
      this.stop()
      if (GlobalStore.pref.dynamicBackgroundStreaming) {
        this.play()
        this.resume()
      }
    }, 100)
  }
  changeColorToDefault() {
    this.onDefaultColor = true;
    if (GlobalStore.isDarkMode) {
      this._changeColor(DarkColor)
    } else {
      this._changeColor(LightColor)
    }
  }
  // TODO: 遗留问题 流光无法动态变化
  stop() {
    // this.controller[this.currentSwitch].stop()
    // this.flowPlayState = FlowPlayState.STOP
  }
  play() {
    // this.controller[this.currentSwitch].play()
    // this.controller[this.currentSwitch].resume()
    // this.flowPlayState = FlowPlayState.PLAY
  }
  pause() {
    // this.controller[this.currentSwitch].pause()
    // this.flowPlayState = FlowPlayState.PAUSED
  }
  resume() {
    // this.controller[this.currentSwitch].resume()
    // this.flowPlayState = FlowPlayState.PLAY
  }
  get paused() {
    return this.flowPlayState === FlowPlayState.PAUSED
  }
  pauseOrPlay() {
    // if (this.paused) {
    //   this.resume()
    // } else {
    //   this.pause()
    // }
  }
}