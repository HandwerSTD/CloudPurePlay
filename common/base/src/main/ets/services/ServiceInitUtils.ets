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
import { SCEmitter, SCPref } from '../exports'
import { EmitterUtil } from '@pura/harmony-utils'

export class ServiceInitUtils {
  static async init() {
    // 初始化全局设置
    Settings.init()
    ServiceInitUtils.loadPresetPreferences()
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
  }
  static loadPresetPreferences() {
    if (Settings.get<boolean>(SCPref.useMissionContinue) === undefined) {
      Settings.put(SCPref.useMissionContinue, true)
    }
    // 启动时自动显示Player
    if (Settings.get<boolean>(SCPref.showPlayerOnLaunch) === undefined) {
      Settings.put(SCPref.showPlayerOnLaunch, true)
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
    UserManager.setUserInfo(newUser, newPasswd);
    await ServiceInitUtils.init()
    EmitterUtil.post(SCEmitter.UserInfoReInit, [])
  }
}