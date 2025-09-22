import { GlobalStore } from "@handwer/base";
import { hdsEffect } from "@kit.UIDesignKit"
import common from "@ohos.app.ability.common";
import { ColorMetrics } from "@kit.ArkUI";
import { ClickUtil } from "@pura/harmony-utils";

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
  flowColorSourceId: string = ''

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
  changeColor(colors: ResourceColor[], id: string, ctx: UIContext) {

    if (GlobalStore.pref.bgFlowColorStrat === 0) {
      this.changeColorToDefault(ctx)
    } else if (this.flowColorSourceId !== id) {
      this._changeColor(colors)
      this.flowColorSourceId = id
      this.setStatusBarColor(colors[0] as string, ctx)
    }

    ClickUtil.throttle(() => {
    })
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
  changeColorToDefault(ctx: UIContext) {
    this.onDefaultColor = true;
    if (GlobalStore.isDarkMode) {
      this._changeColor(DarkColor)
      this.setStatusBarColor('#000000', ctx)
    } else {
      this._changeColor(LightColor)
      this.setStatusBarColor('#ffffff', ctx)
    }
  }
  setStatusBarColor(color: string, ctx: UIContext) {
    const res = this.pickTextColorFromHex(color)
    let col = Color.White
    // 深色模式强制白色状态栏
    if (res === 'black' && GlobalStore.isDarkMode === false) {
      col = Color.Black
    }
    (ctx.getHostContext() as common.UIAbilityContext).windowStage.getMainWindowSync().setStatusBarColor(ColorMetrics.resourceColor(col))
  }
  pickTextColorFromHex(hex: string): "black" | "white" {
    // 去掉 #
    hex = hex.replace(/^#/, "");

    // 支持简写形式 #RGB
    if (hex.length === 3) {
      hex = hex.split("").map(ch => ch + ch).join("");
    }

    if (hex.length !== 6) {
      throw new Error("Invalid hex color: " + hex);
    }

    // 解析 RGB
    const r = parseInt(hex.substring(0, 2), 16);
    const g = parseInt(hex.substring(2, 4), 16);
    const b = parseInt(hex.substring(4, 6), 16);

    // 亮度计算
    const luminance = 0.299 * r + 0.587 * g + 0.114 * b;

    return luminance > 128 ? "black" : "white";
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