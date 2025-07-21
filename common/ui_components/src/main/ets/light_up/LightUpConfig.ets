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
