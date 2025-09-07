import { APIConfigUtils, InstanceSwitcher, PlayQueue, Song } from "@handwer/api_adapter";
import { AbilityConstant, common } from "@kit.AbilityKit";
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
    return {
      requestContextHash: APIConfigUtils.getRequestContextIdentifier(),
      nowPlayingStore: JSON.stringify(NowPlayingStore.toExportable()),
      playQueueStore: JSON.stringify(playQueueStore.toExportable())
    } as MissionContinueData
  }
  static checkContinueData(contextHash: string) {
    return APIConfigUtils.getRequestContextIdentifier() === contextHash;
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