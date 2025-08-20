/**
 * NavidromeAPI Entity to APIAdapter Entity Parser
 * 
 * 用于将NavidromeAPI的实体转换为APIAdapter的实体
 * 主要处理字段映射和结构差异转换
 */

// Import NavidromeAPI entities
import {
  Navidrome_Album,
  Navidrome_AlbumInfoResult,
  Navidrome_AlbumSong,
  Navidrome_SubAlbumResult,
  Navidrome_AlbumSearchResult,
  Navidrome_ArtistInfo,
  Navidrome_ArtistItem,
  Navidrome_ArtistsResult,
  Navidrome_PlayList,
  Navidrome_PlayListsResult,
  Navidrome_PlayListSongsResult,
  Navidrome_Song,
  Navidrome_SongSearchResult,
  Navidrome_SongPlayResult,
  Navidrome_LikeList,
  Navidrome_TopList,
  Navidrome_User,
  Navidrome_LyricResult,
  Navidrome_SongArtist,
  NavidromeAPI_AlbumAPIUtils,
  NavidromeAPI_SongAPIUtils
} from '@handwer/navidrome_api';

// Import APIAdapter entities
import {
  Album,
  AlbumInfoResult,
  SubAlbumResult,
  AlbumSearchResult,
  Artist,
  Song,
  SongSearchResult,
  SongPlayResult,
  ArtistInfo,
  ArtistItem,
  ArtistsResult,
  PlayList,
  PlayListsResult,
  PlayListSong,
  User,
  LyricResult,
  TopListItem
} from '../../common_defs/ExportedEntities';

export class NavidromeAPI_EntityParser {
  
  /**
   * 转换Artist实体
   */
  static parseArtist(navidromeArtist: Navidrome_SongArtist): Artist {
    return {
      id: navidromeArtist.id,
      name: navidromeArtist.name
    };
  }

  /**
   * 转换Artist数组
   */
  static parseArtists(navidromeArtists: Navidrome_SongArtist[]): Artist[] {
    return navidromeArtists?.map(artist => NavidromeAPI_EntityParser.parseArtist(artist)) ?? [];
  }

  /**
   * 转换ArtistItem实体
   */
  static parseArtistItem(navidromeArtistItem: Navidrome_ArtistItem): ArtistItem {
    return {
      id: navidromeArtistItem.id,
      name: navidromeArtistItem.name,
      picUrl: navidromeArtistItem.coverArt ?? '' // Navidrome的coverArt对应CommonDefs的picUrl
    };
  }

  /**
   * 转换ArtistInfo实体
   */
  static parseArtistInfo(navidromeArtistInfo: Navidrome_ArtistInfo): ArtistInfo {
    return {
      artist: {
        briefDesc: '', // Navidrome没有简介字段，使用空字符串
        picUrl: navidromeArtistInfo.coverArt ?? navidromeArtistInfo.artistImageUrl ?? '',
        alias: [], // Navidrome没有别名字段，使用空数组
        name: navidromeArtistInfo.name,
        id: navidromeArtistInfo.id
      },
      hotSongs: [], // Navidrome的ArtistInfo没有直接包含热门歌曲，需要单独获取
      code: 200, // 默认成功码
      more: false // 默认false
    };
  }

  /**
   * 转换ArtistsResult实体
   */
  static parseArtistsResult(navidromeArtistsResult: Navidrome_ArtistsResult): ArtistsResult {
    const artists = navidromeArtistsResult.result.artists ?? [];
    return {
      result: {
        artistCount: artists.length,
        artists: artists.map(artist => NavidromeAPI_EntityParser.parseArtistItem(artist))
      }
    };
  }

  /**
   * 转换Album实体
   */
  static parseAlbum(navidromeAlbum: Navidrome_Album): Album {
    return {
      artists: [{
        id: navidromeAlbum.artistId,
        name: navidromeAlbum.artist
      }], // Navidrome的单个artist转为数组
      picUrl: NavidromeAPI_AlbumAPIUtils.getAlbumCoverUrl(navidromeAlbum) ?? '', // coverArt对应picUrl
      name: navidromeAlbum.name,
      id: navidromeAlbum.id,
      size: navidromeAlbum.songCount ?? 0 // songCount对应size
    };
  }

  /**
   * 转换Album数组
   */
  static parseAlbums(navidromeAlbums: Navidrome_Album[]): Album[] {
    return navidromeAlbums.map(album => NavidromeAPI_EntityParser.parseAlbum(album));
  }

  /**
   * 转换AlbumInfoResult实体
   */
  static parseAlbumInfoResult(navidromeResult: Navidrome_AlbumInfoResult): AlbumInfoResult {
    return {
      code: 200, // 默认成功码
      resourceState: true, // 默认true
      songs: navidromeResult.song.map((song): PlayListSong => ({
        id: song.id,
        ar: [{
          id: song.artistId,
          name: song.artist
        }], // 转换为Artist数组格式
        al: {
          artists: [{
            id: song.artistId,
            name: song.artist
          }],
          picUrl: NavidromeAPI_SongAPIUtils.getSongPicUrl(song.coverArt!) ?? '',
          name: song.album,
          id: song.albumId,
          size: 0 // 默认值
        },
        dt: (song.duration ?? 0) * 1000, // 转换为毫秒
        name: song.title,
        fee: 0 // Navidrome没有收费概念，默认免费
      })),
      album: {
        company: '', // Navidrome没有公司信息
        picUrl: NavidromeAPI_SongAPIUtils.getSongPicUrl(navidromeResult.coverArt!) ?? '',
        description: '', // Navidrome没有描述信息
        name: navidromeResult.name,
        id: navidromeResult.id
      }
    };
  }

  /**
   * 转换SubAlbumResult实体
   */
  static parseSubAlbumResult(navidromeResult: Navidrome_SubAlbumResult): SubAlbumResult {
    return {
      data: NavidromeAPI_EntityParser.parseAlbums(navidromeResult.data)
    };
  }

  /**
   * 转换AlbumSearchResult实体
   */
  static parseAlbumSearchResult(navidromeResult: Navidrome_AlbumSearchResult): AlbumSearchResult {
    return {
      result: {
        albums: NavidromeAPI_EntityParser.parseAlbums(navidromeResult.result.albums)
      }
    };
  }

  /**
   * 转换Song实体
   */
  static parseSong(navidromeSong: Navidrome_Song): Song {
    return {
      id: navidromeSong.id,
      name: navidromeSong.name,
      artists: NavidromeAPI_EntityParser.parseArtists(navidromeSong.artists),
      album: {
        artists: NavidromeAPI_EntityParser.parseArtists(navidromeSong.artists),
        picUrl: navidromeSong.album.coverArt ?? '',
        name: navidromeSong.album.name,
        id: navidromeSong.album.id,
        size: 0 // 默认值
      },
      duration: navidromeSong.duration * 1000, // 转换为毫秒
      alias: [], // Navidrome没有别名
      fee: 0 // 默认免费
    };
  }

  /**
   * 转换Song数组
   */
  static parseSongs(navidromeSongs: Navidrome_Song[]): Song[] {
    return navidromeSongs.map(song => NavidromeAPI_EntityParser.parseSong(song));
  }

  /**
   * 转换SongSearchResult实体
   */
  static parseSongSearchResult(navidromeResult: Navidrome_SongSearchResult): SongSearchResult {
    const songs = navidromeResult.searchResult2.song ?? [];
    return {
      result: {
        songs: NavidromeAPI_EntityParser.parseSongs(songs),
        hasMore: false, // Navidrome搜索结果没有hasMore字段
        songCount: songs.length
      }
    };
  }

  /**
   * 转换SongPlayResult实体
   */
  static parseSongPlayResult(navidromeResult: Navidrome_SongPlayResult): SongPlayResult {
    return {
      data: [{
        id: '', // Navidrome的SongPlayResult只有path，没有id
        url: navidromeResult.path,
        time: Date.now()
      }]
    };
  }

  /**
   * 转换PlayList实体
   */
  static parsePlayList(navidromePlayList: Navidrome_PlayList): PlayList {
    return {
      coverImgUrl: navidromePlayList.coverArt ?? '',
      name: navidromePlayList.name,
      id: navidromePlayList.id,
      playCount: 0, // Navidrome没有播放次数统计
      subscribedCount: 0, // Navidrome没有订阅数统计
      userId: navidromePlayList.owner ?? '',
      trackCount: navidromePlayList.songCount ?? 0,
      subscribed: false, // 默认未订阅
      creator: {
        userId: navidromePlayList.owner ?? '',
        nickname: navidromePlayList.owner ?? '',
        avatarUrl: ''
      },
      description: '' // Navidrome没有描述字段
    };
  }

  /**
   * 转换PlayListsResult实体
   */
  static parsePlayListsResult(navidromeResult: Navidrome_PlayListsResult): PlayListsResult {
    return {
      more: navidromeResult.more,
      playlist: navidromeResult.playlist.map(pl => NavidromeAPI_EntityParser.parsePlayList(pl))
    };
  }

  /**
   * 转换PlayListSongsResult到PlayListSong数组
   */
  static parsePlayListSongs(navidromeResult: Navidrome_PlayListSongsResult): PlayListSong[] {
    return navidromeResult.songs.map((song): PlayListSong => ({
      id: song.id,
      ar: NavidromeAPI_EntityParser.parseArtists(song.artists),
      al: {
        artists: NavidromeAPI_EntityParser.parseArtists(song.artists),
        picUrl: song.album.coverArt ?? '',
        name: song.album.name,
        id: song.album.id,
        size: 0 // 默认值
      },
      dt: song.duration * 1000, // 转换为毫秒
      name: song.name,
      fee: 0 // 默认免费
    }));
  }

  /**
   * 转换User实体
   */
  static parseUser(navidromeUser: Navidrome_User): User {
    return {
      data: {
        account: {
          userName: navidromeUser.username,
          id: navidromeUser.username,
          vipType: 1
        },
        profile: {
          userId: navidromeUser.username,
          nickname: navidromeUser.username,
          backgroundUrl: '',
          avatarUrl: '',
          gender: 0
        }
      }
    };
  }

  /**
   * 转换LyricResult实体
   */
  static parseLyricResult(navidromeLyric: Navidrome_LyricResult): LyricResult {
    return {
      lrc: {
        lyric: navidromeLyric.lyrics?.value ?? ''
      },
      klyric: {
        lyric: ''
      },
      tlyric: {
        lyric: '' // Navidrome没有翻译歌词
      },
      romalrc: {
        lyric: '' // Navidrome没有罗马音歌词
      },
      code: navidromeLyric.status === 'ok' ? 200 : 404 // 根据status判断
    };
  }

  /**
   * 转换TopList实体
   */
  static parseTopListItem(navidromeTopList: Navidrome_TopList): TopListItem {
    return {
      id: '', // Navidrome TopList没有id字段，使用默认值
      name: 'Navidrome Top Songs', // 默认名称
      coverImgUrl: '', // Navidrome TopList没有封面
      playCount: 0,
      subscribedCount: 0,
      trackCount: navidromeTopList.topSongs.length,
      description: 'Top songs from Navidrome',
      updateFrequency: '1'
    };
  }

  /**
   * 从LikeList转换为Song数组
   */
  static parseLikeListToSongs(navidromeLikeList: Navidrome_LikeList): Song[] {
    return NavidromeAPI_EntityParser.parseSongs(navidromeLikeList.data);
  }
}
