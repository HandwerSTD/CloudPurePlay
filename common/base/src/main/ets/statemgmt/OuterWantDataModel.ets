
export type OuterWantType = 'new_config' | 'share_song' | '';

@ObservedV2
export class OuterWantDataModel {
  @Trace type: OuterWantType
  @Trace data: Record<string, Object>

  constructor(t: OuterWantType = '', d: Record<string, Object> = {}) {
    this.type = t;
    this.data = d;
  }
}

// export interface NewConfigOuterWant {
//   apiName: string
//   apiConfig: Object
// }