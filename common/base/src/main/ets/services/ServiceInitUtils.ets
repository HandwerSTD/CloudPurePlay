import playQueueUtils from './PlaybackController/queue/PlayQueueUtils'
import AudioCacheUtils from './PlaybackController/play/system/AudioCacheUtils'
import { PlayControl } from './PlaybackController/play/user/playControl'
import AVPlayerUtils from './PlaybackController/play/system/AVPlayerUtils'
import Settings from './Preferences/PreferenceUtils'
import { CloudAPIConfigUtils, RealIP_INITIAL } from '@handwer/cloud_api'

export class ServiceInitUtils {
  static async init() {
    // API 请求初始化
    CloudAPIConfigUtils.setRequestContext({
      baseUrl: 'http://139.9.223.233:3000/',
      cookie: {},
      realIp: RealIP_INITIAL
    })
    // 初始化全局设置
    Settings.init()
    // 初始化播放器
    await AVPlayerUtils.init()
    // 初始化音频缓存
    await AudioCacheUtils.init()
    // 初始化播放队列
    await playQueueUtils.init()
    // 初始化播放控制
    await PlayControl.init()
  }
}