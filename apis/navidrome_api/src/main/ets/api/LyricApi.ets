import commonRequest from "./request/RequestUtil";

interface Lyric {
  artist: string;
  title: string;
  value: string; // 整段歌词
}

interface LyricResult {
  status: string;
  version: string;
  lyrics?: Lyric;
}

/**
 * 获取歌词（原始结果）
 * @param id - 歌曲id
 */
export const getLyric = async (id: string): Promise<LyricResult> => {
  return commonRequest({
    url: '/rest/getLyrics.view',
    params: { id, f: 'json' }
  });
};

/**
 * 获取歌词文本
 * @param id - 歌曲id
 * @returns - 歌词 string
 */
export const getLyricString = async (id: string): Promise<string> => {
  const response = await commonRequest<LyricResult>({
    url: '/rest/getLyrics.view',
    params: { id, f: 'json' }
  });

  const lyric = response?.lyrics?.value;
  return lyric ?? "[00:00.00] 暂无歌词";
};
