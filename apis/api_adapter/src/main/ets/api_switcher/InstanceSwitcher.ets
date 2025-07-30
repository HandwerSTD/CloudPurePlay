export enum INSTANCE_TYPE {
  WEB_DAV,
  CLOUD
}

export class InstanceSwitcher {
  static _instance?: InstanceSwitcher
  private constructor() {
  }

  getInstance() {
    if (!InstanceSwitcher._instance) {
      InstanceSwitcher._instance = new InstanceSwitcher()
    }
    return InstanceSwitcher._instance
  }

  instanceType: INSTANCE_TYPE = INSTANCE_TYPE.CLOUD
}