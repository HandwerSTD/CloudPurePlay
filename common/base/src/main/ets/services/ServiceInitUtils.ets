import playQueueUtils from './PlaybackController/queue/PlayQueueUtils'
import AudioCacheUtils from './PlaybackController/play/system/AudioCacheUtils'
import { PlayControl } from './PlaybackController/play/user/playControl'
import AVPlayerUtils from './PlaybackController/play/system/AVPlayerUtils'
import Settings from './Preferences/PreferenceUtils'

export class ServiceInitUtils {
  static async init() {
    // 初始化播放队列
    await playQueueUtils.init()
    // 初始化音频缓存
    await AudioCacheUtils.init()
    // 初始化播放控制
    await PlayControl.init()
    // 初始化播放器
    await AVPlayerUtils.init()
    // 初始化全局设置
    Settings.init()
  }
}