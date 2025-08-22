export enum INSTANCE_TYPE {
  NAVIDROME,
  CLOUD
}

const InstanceTypeName: Record<INSTANCE_TYPE, string> = {
  0: "Navidrome",
  1: "CloudAPI"
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
  static get InstanceTypeName() {
    return InstanceTypeName[InstanceSwitcher.InstanceType]
  }
  static getInstanceNameByType(type: INSTANCE_TYPE) {
    return InstanceTypeName[type]
  }
  static getTypeByName(name: string) {
    for (let i = 0; i < 2; ++i) {
      if (InstanceTypeName[i] === name) return i;
    }
    return -1;
  }
}
