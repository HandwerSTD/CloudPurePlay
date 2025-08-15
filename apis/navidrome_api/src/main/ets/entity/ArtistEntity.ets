/** 单个歌手信息 */
export interface ArtistInfo {
  id: number;
  name: string;
  albumCount: number;
  songCount: number;
  coverArt?: string;         // 封面ID，可用于生成图片URL
  artistImageUrl?: string;   // 可选字段，完整图片URL
}

/** 搜索结果里的歌手项 */
export interface ArtistItem {
  id: number;
  name: string;
  albumCount: number;
  songCount: number;
  coverArt?: string;
}

/** 搜索歌手返回结果 */
interface ArtistResult_Inner {
  artists: ArtistItem[] | null;
}

export interface ArtistsResult {
  result: ArtistResult_Inner;
}
