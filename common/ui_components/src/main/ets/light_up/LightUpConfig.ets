export interface LightUpConfig {
  lightIntensity?: number
  lightHeight?: Dimension
  lightBloom?: number
}

export const LightUpDefaultConfig: LightUpConfig = {
  lightIntensity: 1,
  lightHeight: 150,
  lightBloom: 0
}

export const LightUpLinedDefaultConfig: LightUpConfig = {lightIntensity: 0.7, lightHeight: 80 }

export enum OverrideLightUpStat {
  NO_OVERRIDE,
  ALWAYS_DISABLED,
  ALWAYS_ENABLED
}