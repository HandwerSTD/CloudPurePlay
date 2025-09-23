import playQueueUtils from './PlaybackController/queue/PlayQueueUtils'
import AudioCacheUtils from './PlaybackController/play/system/AudioCacheUtils'
import { PlayControl } from './PlaybackController/play/user/playControl'
import AVPlayerUtils from './PlaybackController/play/system/AVPlayerUtils'
import Settings from './Preferences/PreferenceUtils'
import {
  APIConfigUtils,
  InstanceSwitcher,
  INSTANCE_TYPE, User,
} from '@handwer/api_adapter'
import { UserManager } from './Network/UserManager'
import { DistributedUtils, FeaturedPlayUtils, GlobalStore,
  Logger,
  NowPlayingStore,
  PlayQueueStore,
  SCEmitter, SCPref,
  ThemeManager } from '../exports'
import { EmitterUtil } from '@pura/harmony-utils'
import { playQueueKV } from './PlaybackController/queue/PlayQueueStore'

const TAG = '[ServiceInitUtils]'

export class ServiceInitUtils {
  static async init() {
    Logger.debug(TAG, `service initialize`)
    const isContinuation = GlobalStore.continuationInfo !== undefined;
    if (isContinuation) {
      Logger.debug(TAG, `isContinuation`)
      const info = GlobalStore.continuationInfo!
      // play queue
      playQueueKV.init()
      PlayQueueStore.fromExportable(JSON.parse(info.playQueueStore))
      playQueueUtils.syncQueueToStorage();
      // now playing
      PlayControl.initKV()
      NowPlayingStore.fromExportable(JSON.parse(info.nowPlayingStore))
      PlayControl.syncToStorage()
    }
    // 初始化全局设置
    Settings.init()
    ServiceInitUtils.loadPresetPreferences()
    ServiceInitUtils.loadViewPref()
    // 初始化 API
    InstanceSwitcher.InstanceType = Settings.get<INSTANCE_TYPE>(SCPref.apiInstanceType) ?? INSTANCE_TYPE.CLOUD
    APIConfigUtils.loadRequestContext(Settings.get(SCPref.currentAPIConfig) ?? APIConfigUtils.EmptyConfig)
    // 初始化播放器
    await AVPlayerUtils.init()
    // 初始化音频缓存
    await AudioCacheUtils.init()
    // 初始化播放队列
    await playQueueUtils.init()
    // 初始化播放控制
    await PlayControl.init()
    // 初始化用户信息
    await UserManager.init()
    if (Settings.get<boolean>(SCPref.autoPlayFM) === true) {
      if (playQueueUtils.getQueueLength() === 0) {
        FeaturedPlayUtils.playPersonalizedFM(() => {})
      }
    }
    GlobalStore.initialized = true
  }
  static loadViewPref() {
    const pref = GlobalStore.pref
    pref.tabRightHand = Settings.get<boolean>(SCPref.navigationRightHandMode) ?? false
    pref.playerRightHand = Settings.get<boolean>(SCPref.playerTwoColumnRightHandMode) ?? false
    pref.autoNavRightHandMode = Settings.get<boolean>(SCPref.autoNavRightHand) ?? false
    pref.useStylusControl = Settings.get<boolean>(SCPref.useStylusControl) ?? false
    pref.dynamicBackgroundStreaming = Settings.get<boolean>(SCPref.dynamicBackgroundStreaming) ?? false
    pref.bgFlowColorStrat = Settings.get<number>(SCPref.bgFlowColorStrat) ?? 1
  }
  static loadPresetPreferences() {
    if (Settings.get<boolean>(SCPref.useMissionContinue) === undefined) {
      Settings.put(SCPref.useMissionContinue, true)
    }
    // 启动时自动显示Player
    if (Settings.get<boolean>(SCPref.showPlayerOnLaunch) === undefined) {
      Settings.put(SCPref.showPlayerOnLaunch, true)
    }
    if (Settings.get<boolean>(SCPref.autoPlayFM) === undefined) {
      Settings.put(SCPref.autoPlayFM, true)
    }
    if (Settings.get<boolean>(SCPref.useStylusControl) === undefined) {
      Settings.put(SCPref.useStylusControl, true)
    }
    if (Settings.get<boolean>(SCPref.autoNavRightHand) === undefined) {
      Settings.put(SCPref.autoNavRightHand, false)
    }
    if (Settings.get<boolean>(SCPref.autoPlayOnLaunch) === undefined) {
      Settings.put(SCPref.autoPlayOnLaunch, true)
    }
    if (Settings.get<boolean>(SCPref.dynamicBackgroundStreaming) === undefined) {
      Settings.put(SCPref.dynamicBackgroundStreaming, false)
    }
    if (Settings.get<number>(SCPref.bgFlowColorStrat) === undefined) {
      Settings.put(SCPref.bgFlowColorStrat, 1)
    }
  }
  static async reInit(newInstanceType: INSTANCE_TYPE, newUser: User, newPasswd: string, newRequestContext: Object) {
    // 清除全部用户信息
    UserManager.clearAllUserData();
    // 清除全部播放信息
    await PlayControl.clearCurrentSong();
    await playQueueUtils.cleanQueue();
    // 写入新 API 信息
    InstanceSwitcher.InstanceType = newInstanceType;
    APIConfigUtils.loadRequestContext(newRequestContext);
    Settings.put(SCPref.apiInstanceType, newInstanceType);
    Settings.put(SCPref.currentAPIConfig, newRequestContext);
    DistributedUtils.writeRequestContext(newInstanceType, {
      'context': newRequestContext
    })
    UserManager.setUserInfo(newUser, newPasswd);
    await ServiceInitUtils.init()
    EmitterUtil.post(SCEmitter.UserInfoReInit, [])
  }
}