
interface backButtonFunction {
  id: string
  judge: () => boolean
  action: () => void
}

export class BackButtonUtils {

  backButtonFuncs: backButtonFunction[] = []

  registerBackButton(param: backButtonFunction) {
    this.backButtonFuncs.push({
      id: param.id,
      judge: () => { return param.judge() },
      action: () => { param.action() }
    } as backButtonFunction)
  }
  unregisterBackButton(id: string) {
    const idx = this.backButtonFuncs.findIndex(val => val.id === id);
    if (idx !== -1) this.backButtonFuncs.splice(idx, 1)
  }
}

export default new BackButtonUtils()