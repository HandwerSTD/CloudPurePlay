export enum INSTANCE_TYPE {
  WEB_DAV,
  CLOUD
}

export class InstanceSwitcher {
  static _instance?: InstanceSwitcher
  private constructor() {
  }

  static getInstance() {
    if (!InstanceSwitcher._instance) {
      InstanceSwitcher._instance = new InstanceSwitcher()
    }
    return InstanceSwitcher._instance
  }

  instanceType: INSTANCE_TYPE = INSTANCE_TYPE.CLOUD

  static get InstanceType() {
    return InstanceSwitcher.getInstance().instanceType
  }
  static set InstanceType(type: INSTANCE_TYPE) {
    InstanceSwitcher.getInstance().instanceType = type
  }
}
