import { Album, PlayList } from "@handwer/api_adapter"
import { SongConvertUtils } from "@handwer/base"
import { WearableMusicLibraryConfig } from "../config/WearableMusicLibraryConfig"

/**
 * 可穿戴设备音乐库工具类
 */
export class WearableMusicUtils {
  
  /**
   * 截断文本以适应小屏幕显示
   */
  static truncateText(text: string, maxLength: number = WearableMusicLibraryConfig.MAX_TITLE_LENGTH): string {
    if (text.length <= maxLength) {
      return text
    }
    return text.substring(0, maxLength - 3) + '...'
  }
  
  /**
   * 格式化播放列表信息
   */
  static formatPlaylistInfo(playlist: PlayList): string {
    const count = playlist.trackCount || 0
    return count === 1 ? '1 song' : `${count} songs`
  }
  
  /**
   * 格式化专辑信息
   */
  static formatAlbumInfo(album: Album): string {
    return SongConvertUtils.getArtists(album.artists)
  }
  
  /**
   * 获取适合可穿戴设备的图片URL
   * 优先使用较小尺寸的图片以节省带宽和内存
   */
  static getOptimizedImageUrl(originalUrl: string): string {
    // 如果URL包含尺寸参数，尝试替换为较小尺寸
    if (originalUrl.includes('?param=')) {
      return originalUrl.replace(/\?param=\d+y\d+/, '?param=100y100')
    }
    
    // 如果URL包含其他尺寸参数格式，也进行替换
    if (originalUrl.includes('_')) {
      return originalUrl.replace(/_\d+x\d+/, '_100x100')
    }
    
    return originalUrl
  }
  
  /**
   * 检查是否为用户创建的播放列表
   */
  static isUserCreatedPlaylist(playlist: PlayList, userId: string): boolean {
    return playlist.userId === userId
  }
  
  /**
   * 过滤搜索结果，限制数量以适应小屏幕
   */
  static filterSearchResults<T>(items: T[], maxCount: number = WearableMusicLibraryConfig.MAX_VISIBLE_ITEMS): T[] {
    return items.slice(0, maxCount)
  }
  
  /**
   * 生成可穿戴设备适用的动画配置
   */
  static getWearableAnimationConfig() {
    return {
      duration: WearableMusicLibraryConfig.TRANSITION_DURATION,
      curve: WearableMusicLibraryConfig.SPRING_CURVE
    } as AnimateParam
  }
}
