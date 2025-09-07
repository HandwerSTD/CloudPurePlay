@ObservedV2
export class OuterWantDataModel {
  @Trace type: 'new_config' | ''
  @Trace data: Record<string, Object>

  constructor(t: 'new_config' | '', d: Record<string, Object>) {
    this.type = t;
    this.data = d;
  }
}

// export interface NewConfigOuterWant {
//   apiName: string
//   apiConfig: Object
// }