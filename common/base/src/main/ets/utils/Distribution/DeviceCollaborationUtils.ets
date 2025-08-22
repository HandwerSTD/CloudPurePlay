import { APIConfigUtils, InstanceSwitcher, PlayQueue, Song } from "@handwer/api_adapter";
import { AbilityConstant, common } from "@kit.AbilityKit";
import { MD5 } from "@pura/harmony-utils";
import { NowPlayingStore, SCPref, Settings } from "../../exports";
import { playQueueStore } from "../../services/PlaybackController/queue/PlayQueueStore";

export class DeviceCollaborationUtils {
  static async setCanMissionContinue(context: common.UIAbilityContext) {
    if (Settings.get<boolean>(SCPref.useMissionContinue)) {
      context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE)
      return true;
    }
    return false;
  }
  static async setDisableMissionContinue(context: common.UIAbilityContext) {
    context.setMissionContinueState(AbilityConstant.ContinueState.INACTIVE)
  }
  static async generateContinueData() {
    const requestAPI = `${InstanceSwitcher.InstanceTypeName}_${JSON.stringify(APIConfigUtils.NowRequestContext ?? '')}`
    return {
      requestContextHash: MD5.digestSync(requestAPI),
      nowPlayingStore: JSON.stringify(NowPlayingStore.toExportable()),
      playQueueStore: JSON.stringify(playQueueStore.toExportable())
    } as MissionContinueData
  }
  static checkContinueData(contextHash: string) {
    const requestAPI = `${InstanceSwitcher.InstanceTypeName}_${JSON.stringify(APIConfigUtils.NowRequestContext ?? '')}`
    return MD5.digestSync(requestAPI) === contextHash;
  }
  static async applyContinuation(data: MissionContinueData) {
    NowPlayingStore.fromExportable(JSON.parse(data.nowPlayingStore))
    playQueueStore.fromExportable(JSON.parse(data.playQueueStore))
  }
}

export interface MissionContinueData {
  requestContextHash: string,
  nowPlayingStore: string,
  playQueueStore: string
}