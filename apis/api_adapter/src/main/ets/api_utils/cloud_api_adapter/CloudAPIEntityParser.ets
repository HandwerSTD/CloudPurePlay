/**
 * CloudAPI Entity to APIAdapter Entity Parser
 * 
 * 用于将CloudAPI的实体转换为APIAdapter的实体
 * 主要处理ID类型从number到string的转换，以及其他类型差异
 */

// Import CloudAPI entities
import {
  CloudAPI_Album,
  CloudAPI_AlbumInfoResult,
  CloudAPI_SubAlbumResult,
  CloudAPI_AlbumSearchResult,
  CloudAPI_Artist,
  CloudAPI_Song,
  CloudAPI_SongSearchResult,
  CloudAPI_SongDetail,
  CloudAPI_SongDownloadItem,
  CloudAPI_SongDownload,
  CloudAPI_SongPlayResult,
  CloudAPI_LocalSong,
  CloudAPI_Comment,
  CloudAPI_CommentResult,
  CloudAPI_Creator,
  CloudAPI_PlayList,
  CloudAPI_PlayListResult,
  CloudAPI_PlayListOperationResult,
  CloudAPI_PlayListsResult,
  CloudAPI_PlayListSearchResult,
  CloudAPI_PlayingPlayList,
  CloudAPI_User,
  CloudAPI_DjRadio,
  CloudAPI_DjResult,
  CloudAPI_DjProgramResult,
  CloudAPI_DjRadioProgram,
  CloudAPI_RecommendDjRadio,
  CloudAPI_DjRecommendResult,
  CloudAPI_Dj,
  CloudAPI_LyricResult,
  CloudAPI_QualityType,
  CloudAPI_HeartMode,
  CloudAPI_PersonalListItem,
  CloudAPI_Personalized,
  CloudAPI_TopListItem,
  CloudAPI_TopList,
  CloudAPI_ArtistInfo,
  CloudAPI_ArtistItem,
  CloudAPI_ArtistsResult,
  CloudAPI_SearchReturn,
  CloudAPI_DailySongRes
} from '@handwer/cloud_api';

// Import APIAdapter entities
import {
  Album,
  AlbumInfoResult,
  SubAlbumResult,
  AlbumSearchResult,
  Artist,
  Song,
  SongSearchResult,
  SongDetail,
  SongDownloadItem,
  SongDownload,
  SongPlayResult,
  LocalSong,
  Comment,
  CommentResult,
  Creator,
  PlayList,
  PlayListResult,
  PlayListOperationResult,
  PlayListsResult,
  PlayListSearchResult,
  PlayingPlayList,
  User,
  DjRadio,
  DjResult,
  DjProgramResult,
  DjRadioProgram,
  RecommendDjRadio,
  DjRecommendResult,
  Dj,
  LyricResult,
  QualityType,
  HeartMode,
  PersonalListItem,
  Personalized,
  TopListItem,
  TopList,
  SearchReturn,
  PlayListSong,
  SongDetailItem,
  Al,
  SongPlayData,
  ResultData,
  SongInfo,
  ArtistInfo,
  ArtistItem,
  ArtistsResult,
  DailySongRes
} from '../../common_defs/ExportedEntities';

export class CloudAPIEntityParser {
  
  /**
   * 转换Artist实体
   */
  static parseArtist(cloudArtist: CloudAPI_Artist): Artist {
    return {
      id: cloudArtist.id.toString(),
      name: cloudArtist.name
    };
  }

  /**
   * 转换Artist数组
   */
  static parseArtists(cloudArtists: CloudAPI_Artist[]): Artist[] {
    return cloudArtists?.map(artist => CloudAPIEntityParser.parseArtist(artist)) ?? [];
  }

  /**
   * 转换ArtistItem实体
   */
  static parseArtistItem(cloudArtistItem: CloudAPI_ArtistItem): ArtistItem {
    return {
      id: cloudArtistItem.id.toString(),
      name: cloudArtistItem.name,
      picUrl: cloudArtistItem.picUrl
    };
  }

  /**
   * 转换ArtistInfo实体
   */
  static parseArtistInfo(cloudArtistInfo: CloudAPI_ArtistInfo): ArtistInfo {
    return {
      artist: {
        briefDesc: cloudArtistInfo.artist.briefDesc,
        picUrl: cloudArtistInfo.artist.picUrl,
        alias: cloudArtistInfo.artist.alias,
        name: cloudArtistInfo.artist.name,
        id: cloudArtistInfo.artist.id.toString()
      },
      hotSongs: cloudArtistInfo.hotSongs.map(song => ({
        id: song.id.toString(),
        ar: CloudAPIEntityParser.parseArtists(song.ar),
        al: CloudAPIEntityParser.parseAlbum(song.al),
        dt: song.dt,
        name: song.name,
        fee: song.fee
      } as PlayListSong)),
      code: cloudArtistInfo.code,
      more: cloudArtistInfo.more
    };
  }

  /**
   * 转换ArtistsResult实体
   */
  static parseArtistsResult(cloudArtistsResult: CloudAPI_ArtistsResult): ArtistsResult {
    return {
      result: {
        artistCount: cloudArtistsResult.result.artistCount,
        artists: cloudArtistsResult.result.artists.map(artist => CloudAPIEntityParser.parseArtistItem(artist))
      }
    };
  }

  /**
   * 转换Album实体
   */
  static parseAlbum(cloudAlbum: CloudAPI_Album): Album {
    return {
      artists: CloudAPIEntityParser.parseArtists(cloudAlbum.artists),
      picUrl: cloudAlbum.picUrl,
      name: cloudAlbum.name,
      id: cloudAlbum.id.toString(),
      size: cloudAlbum.size
    };
  }

  /**
   * 转换Album数组
   */
  static parseAlbums(cloudAlbums: CloudAPI_Album[]): Album[] {
    return cloudAlbums.map(album => CloudAPIEntityParser.parseAlbum(album));
  }

  /**
   * 转换AlbumInfoResult实体
   */
  static parseAlbumInfoResult(cloudResult: CloudAPI_AlbumInfoResult): AlbumInfoResult {
    return {
      code: cloudResult.code,
      resourceState: cloudResult.resourceState,
      songs: cloudResult.songs.map((song): PlayListSong => ({
        id: song.id.toString(),
        ar: CloudAPIEntityParser.parseArtists(song.ar),
        al: CloudAPIEntityParser.parseAlbum(song.al),
        name: song.name,
        dt: song.dt,
        fee: song.fee,
      } as PlayListSong)),
      album: {
        company: cloudResult.album.company,
        picUrl: cloudResult.album.picUrl,
        description: cloudResult.album.description,
        name: cloudResult.album.name,
        id: cloudResult.album.id.toString()
      }
    };
  }

  /**
   * 转换SubAlbumResult实体
   */
  static parseSubAlbumResult(cloudResult: CloudAPI_SubAlbumResult): SubAlbumResult {
    return {
      data: CloudAPIEntityParser.parseAlbums(cloudResult.data)
    };
  }

  /**
   * 转换AlbumSearchResult实体
   */
  static parseAlbumSearchResult(cloudResult: CloudAPI_AlbumSearchResult): AlbumSearchResult {
    return {
      result: {
        albums: CloudAPIEntityParser.parseAlbums(cloudResult.result.albums)
      }
    };
  }

  /**
   * 转换Song实体
   */
  static parseSong(cloudSong: CloudAPI_Song): Song {
    return {
      id: cloudSong.id.toString(),
      name: cloudSong.name,
      artists: CloudAPIEntityParser.parseArtists(cloudSong.artists),
      album: CloudAPIEntityParser.parseAlbum(cloudSong.album),
      duration: cloudSong.duration,
      alias: cloudSong.alias,
      fee: cloudSong.fee
    };
  }

  /**
   * 转换Song数组
   */
  static parseSongs(cloudSongs: CloudAPI_Song[]): Song[] {
    return cloudSongs.map(song => CloudAPIEntityParser.parseSong(song));
  }

  /**
   * 转换SongSearchResult实体
   */
  static parseSongSearchResult(cloudResult: CloudAPI_SongSearchResult): SongSearchResult {
    return {
      result: {
        songs: CloudAPIEntityParser.parseSongs(cloudResult.result.songs),
        hasMore: cloudResult.result.hasMore,
        songCount: cloudResult.result.songCount
      }
    };
  }

  /**
   * 转换SongDetail实体
   */
  static parseSongDetail(cloudDetail: CloudAPI_SongDetail): SongDetail {
    return {
      songs: cloudDetail.songs.map(song => ({
        al: {
          picUrl: song.al.picUrl
        } as Al
      } as SongDetailItem))
    };
  }

  /**
   * 转换音质类型
   */
  static parseQualityType(cloudQuality: CloudAPI_QualityType): QualityType {
    return cloudQuality as QualityType;
  }

  /**
   * 转换SongDownloadItem实体
   */
  static parseSongDownloadItem(cloudItem: CloudAPI_SongDownloadItem): SongDownloadItem {
    return {
      id: cloudItem.id.toString(),
      url: cloudItem.url,
      size: cloudItem.size,
      type: cloudItem.type,
      level: CloudAPIEntityParser.parseQualityType(cloudItem.level)
    };
  }

  /**
   * 转换SongDownload实体
   */
  static parseSongDownload(cloudDownload: CloudAPI_SongDownload): SongDownload {
    return {
      data: cloudDownload.data.map(item => CloudAPIEntityParser.parseSongDownloadItem(item))
    };
  }

  /**
   * 转换SongPlayResult实体
   */
  static parseSongPlayResult(cloudResult: CloudAPI_SongPlayResult): SongPlayResult {
    return {
      data: cloudResult.data.map(item => ({
        id: item.id.toString(),
        url: item.url,
        time: item.time
      } as SongPlayData))
    };
  }

  /**
   * 转换LocalSong实体
   */
  static parseLocalSong(cloudSong: CloudAPI_LocalSong): LocalSong {
    return {
      id: cloudSong.id.toString(),
      songId: cloudSong.songId.toString(),
      name: cloudSong.name,
      artists: cloudSong.artists,
      picFile: cloudSong.picFile,
      songFile: cloudSong.songFile,
      lyricFile: cloudSong.lyricFile
    };
  }

  /**
   * 转换Comment实体
   */
  static parseComment(cloudComment: CloudAPI_Comment): Comment {
    return {
      user: {
        avatarUrl: cloudComment.user.avatarUrl,
        nickname: cloudComment.user.nickname,
        userId: cloudComment.user.userId.toString(),
        vipType: cloudComment.user.vipType
      },
      commentId: cloudComment.commentId.toString(),
      content: cloudComment.content,
      time: cloudComment.time,
      timeStr: cloudComment.timeStr,
      likedCount: cloudComment.likedCount
    };
  }

  /**
   * 转换CommentResult实体
   */
  static parseCommentResult(cloudResult: CloudAPI_CommentResult): CommentResult {
    return {
      code: cloudResult.code,
      data: {
        commentsTitle: cloudResult.data.commentsTitle,
        comments: cloudResult.data.comments.map(comment => CloudAPIEntityParser.parseComment(comment))
      }
    };
  }

  /**
   * 转换Creator实体
   */
  static parseCreator(cloudCreator: CloudAPI_Creator): Creator {
    return {
      userId: cloudCreator.userId.toString(),
      nickname: cloudCreator.nickname,
      avatarUrl: cloudCreator.avatarUrl
    };
  }

  /**
   * 转换PlayList实体
   */
  static parsePlayList(cloudPlayList: CloudAPI_PlayList): PlayList {
    return {
      coverImgUrl: cloudPlayList.coverImgUrl,
      name: cloudPlayList.name,
      id: cloudPlayList.id.toString(),
      playCount: cloudPlayList.playCount,
      subscribedCount: cloudPlayList.subscribedCount,
      userId: cloudPlayList.userId.toString(),
      trackCount: cloudPlayList.trackCount,
      subscribed: cloudPlayList.subscribed,
      creator: CloudAPIEntityParser.parseCreator(cloudPlayList.creator),
      description: cloudPlayList.description
    };
  }

  /**
   * 转换PlayList数组
   */
  static parsePlayLists(cloudPlayLists: CloudAPI_PlayList[]): PlayList[] {
    return cloudPlayLists.map(playList => CloudAPIEntityParser.parsePlayList(playList));
  }

  /**
   * 转换PlayListResult实体
   */
  static parsePlayListResult(cloudResult: CloudAPI_PlayListResult): PlayListResult {
    return {
      more: cloudResult.more,
      playlist: CloudAPIEntityParser.parsePlayLists(cloudResult.playlist)
    };
  }

  /**
   * 转换PlayListOperationResult实体
   */
  static parsePlayListOperationResult(cloudResult: CloudAPI_PlayListOperationResult): PlayListOperationResult {
    return {
      status: cloudResult.status,
      body: {
        code: cloudResult.body.code,
        message: cloudResult.body.message
      }
    };
  }

  /**
   * 转换PlayListsResult实体
   */
  static parsePlayListsResult(cloudResult: CloudAPI_PlayListsResult): PlayListsResult {
    return {
      more: cloudResult.more,
      playlist: CloudAPIEntityParser.parsePlayLists(cloudResult.playlist)
    };
  }

  /**
   * 转换PlayListSearchResult实体
   */
  static parsePlayListSearchResult(cloudResult: CloudAPI_PlayListSearchResult): PlayListSearchResult {
    return {
      code: cloudResult.code,
      result: {
        hasMore: cloudResult.result.hasMore,
        playlists: CloudAPIEntityParser.parsePlayLists(cloudResult.result.playlists)
      }
    };
  }

  /**
   * 转换PlayingPlayList实体
   */
  static parsePlayingPlayList(cloudPlayList: CloudAPI_PlayingPlayList): PlayingPlayList {
    return {
      id: cloudPlayList.id.toString(),
      count: cloudPlayList.count
    };
  }

  /**
   * 转换User实体
   */
  static parseUser(cloudUser: CloudAPI_User): User {
    return {
      data: {
        account: {
          id: cloudUser.data.account.id.toString(),
          userName: cloudUser.data.account.userName,
          vipType: cloudUser.data.account.vipType
        },
        profile: {
          userId: cloudUser.data.profile.userId.toString(),
          nickname: cloudUser.data.profile.nickname,
          avatarUrl: cloudUser.data.profile.avatarUrl,
          backgroundUrl: cloudUser.data.profile.backgroundUrl,
          gender: cloudUser.data.profile.gender
        }
      }
    };
  }

  /**
   * 转换Dj实体
   */
  static parseDj(cloudDj: CloudAPI_Dj): Dj {
    return {
      avatarUrl: cloudDj.avatarUrl,
      userId: cloudDj.userId.toString(),
      nickname: cloudDj.nickname,
      backgroundUrl: cloudDj.backgroundUrl
    };
  }

  /**
   * 转换DjRadio实体
   */
  static parseDjRadio(cloudDjRadio: CloudAPI_DjRadio): DjRadio {
    return {
      dj: CloudAPIEntityParser.parseDj(cloudDjRadio.dj),
      category: cloudDjRadio.category,
      secondCategory: cloudDjRadio.secondCategory,
      buyed: cloudDjRadio.buyed,
      lastProgramName: cloudDjRadio.lastProgramName,
      intervenePicUrl: cloudDjRadio.intervenePicUrl,
      subCount: cloudDjRadio.subCount,
      programCount: cloudDjRadio.programCount,
      picUrl: cloudDjRadio.picUrl,
      lastProgramId: cloudDjRadio.lastProgramId.toString(),
      desc: cloudDjRadio.desc,
      name: cloudDjRadio.name,
      id: cloudDjRadio.id.toString()
    };
  }

  /**
   * 转换DjResult实体
   */
  static parseDjResult(cloudResult: CloudAPI_DjResult): DjResult {
    return {
      code: cloudResult.code,
      djRadios: cloudResult.djRadios.map(radio => CloudAPIEntityParser.parseDjRadio(radio)),
      count: cloudResult.count,
      hasMore: cloudResult.hasMore
    };
  }

  /**
   * 转换DjRadioProgram实体
   */
  static parseDjRadioProgram(cloudProgram: CloudAPI_DjRadioProgram): DjRadioProgram {
    return {
      mainSong: CloudAPIEntityParser.parseSong(cloudProgram.mainSong),
      dj: CloudAPIEntityParser.parseDj(cloudProgram.dj),
      radio: CloudAPIEntityParser.parseDjRadio(cloudProgram.radio),
      coverUrl: cloudProgram.coverUrl
    };
  }

  /**
   * 转换DjProgramResult实体
   */
  static parseDjProgramResult(cloudResult: CloudAPI_DjProgramResult): DjProgramResult {
    return {
      count: cloudResult.count,
      code: cloudResult.code,
      more: cloudResult.more,
      programs: cloudResult.programs.map(program => CloudAPIEntityParser.parseDjRadioProgram(program))
    };
  }

  /**
   * 转换RecommendDjRadio实体
   */
  static parseRecommendDjRadio(cloudRecommend: CloudAPI_RecommendDjRadio): RecommendDjRadio {
    return {
      id: cloudRecommend.id.toString(),
      name: cloudRecommend.name,
      picUrl: cloudRecommend.picUrl,
      categoryId: cloudRecommend.categoryId.toString(),
      category: cloudRecommend.category,
      rcmdtext: cloudRecommend.rcmdtext,
      playCount: cloudRecommend.playCount,
      dj: CloudAPIEntityParser.parseDj(cloudRecommend.dj),
      copywriter: cloudRecommend.copywriter,
      buyed: cloudRecommend.buyed
    };
  }

  /**
   * 转换DjRecommendResult实体
   */
  static parseDjRecommendResult(cloudResult: CloudAPI_DjRecommendResult): DjRecommendResult {
    return {
      djRadios: cloudResult.djRadios.map(radio => CloudAPIEntityParser.parseRecommendDjRadio(radio))
    };
  }

  /**
   * 转换LyricResult实体
   */
  static parseLyricResult(cloudResult: CloudAPI_LyricResult): LyricResult {
    return {
      code: cloudResult.code,
      lrc: {
        lyric: cloudResult.lrc.lyric
      },
      tlyric: {
        lyric: cloudResult.tlyric.lyric
      },
      klyric: {
        lyric: cloudResult.klyric.lyric
      },
      romalrc: {
        lyric: cloudResult.romalrc.lyric
      }
    };
  }

  /**
   * 转换HeartMode实体
   */
  static parseHeartMode(cloudHeartMode: CloudAPI_HeartMode): HeartMode {
    return {
      code: cloudHeartMode.code,
      data: cloudHeartMode.data.map(item => ({
        songInfo: {
          id: item.songInfo.id.toString(),
          name: item.songInfo.name,
          ar: CloudAPIEntityParser.parseArtists(item.songInfo.ar),
          dt: item.songInfo.dt,
          al: CloudAPIEntityParser.parseAlbum(item.songInfo.al),
          fee: item.songInfo.fee
        } as SongInfo
      } as ResultData))
    };
  }

  /**
   * 转换PersonalListItem实体
   */
  static parsePersonalListItem(cloudItem: CloudAPI_PersonalListItem): PersonalListItem {
    return {
      id: cloudItem.id.toString(),
      type: cloudItem.type,
      name: cloudItem.name,
      copywriter: cloudItem.copywriter,
      picUrl: cloudItem.picUrl,
      playCount: cloudItem.playCount,
      trackCount: cloudItem.trackCount
    };
  }

  /**
   * 转换Personalized实体
   */
  static parsePersonalized(cloudPersonalized: CloudAPI_Personalized): Personalized {
    return {
      hasTaste: cloudPersonalized.hasTaste,
      code: cloudPersonalized.code,
      result: cloudPersonalized.result.map(item => CloudAPIEntityParser.parsePersonalListItem(item))
    };
  }

  /**
   * 转换TopListItem实体
   */
  static parseTopListItem(cloudItem: CloudAPI_TopListItem): TopListItem {
    return {
      id: cloudItem.id.toString(),
      name: cloudItem.name,
      trackCount: cloudItem.trackCount,
      updateFrequency: cloudItem.updateFrequency,
      coverImgUrl: cloudItem.coverImgUrl,
      description: cloudItem.description,
      playCount: cloudItem.playCount,
      subscribedCount: cloudItem.subscribedCount
    };
  }

  /**
   * 转换TopList实体
   */
  static parseTopList(cloudTopList: CloudAPI_TopList): TopList {
    return {
      code: cloudTopList.code,
      list: cloudTopList.list.map(item => CloudAPIEntityParser.parseTopListItem(item))
    };
  }

  /**
   * 转换SearchReturn实体（基于SongSearchResult）
   */
  static parseSearchReturn(cloudSongSearchResult: CloudAPI_SearchReturn): SearchReturn {
    return {
      list: CloudAPIEntityParser.parseSongs(cloudSongSearchResult.list),
      hasMore: cloudSongSearchResult.hasMore,
      songCount: cloudSongSearchResult.songCount
    };
  }

  /**
   * 转换DailyListSongs到DailySongRes数组
   */
  static parseDailyListSongs(cloudDailySongs: CloudAPI_DailySongRes[]): DailySongRes[] {
    return cloudDailySongs.map(dailySong => ({
      song: {
        id: dailySong.song.id.toString(),
        name: dailySong.song.name,
        artists: CloudAPIEntityParser.parseArtists(dailySong.song.artists),
        album: CloudAPIEntityParser.parseAlbum(dailySong.song.album),
        duration: dailySong.song.duration,
        alias: [],
        fee: dailySong.song.fee
      },
      reason: dailySong.reason,
      picUrl: dailySong.picUrl
    } as DailySongRes));
  }

  /**
   * 批量转换工具方法
   */
  static batchParseAlbums(cloudAlbums: CloudAPI_Album[]): Album[] {
    return CloudAPIEntityParser.parseAlbums(cloudAlbums);
  }

  static batchParseSongs(cloudSongs: CloudAPI_Song[]): Song[] {
    return CloudAPIEntityParser.parseSongs(cloudSongs);
  }

  static batchParseArtists(cloudArtists: CloudAPI_Artist[]): Artist[] {
    return CloudAPIEntityParser.parseArtists(cloudArtists);
  }

  static batchParsePlayLists(cloudPlayLists: CloudAPI_PlayList[]): PlayList[] {
    return CloudAPIEntityParser.parsePlayLists(cloudPlayLists);
  }

  static batchParseComments(cloudComments: CloudAPI_Comment[]): Comment[] {
    return cloudComments.map(comment => CloudAPIEntityParser.parseComment(comment));
  }

  static batchParseDjRadios(cloudDjRadios: CloudAPI_DjRadio[]): DjRadio[] {
    return cloudDjRadios.map(radio => CloudAPIEntityParser.parseDjRadio(radio));
  }

  static batchParsePersonalListItems(cloudItems: CloudAPI_PersonalListItem[]): PersonalListItem[] {
    return cloudItems.map(item => CloudAPIEntityParser.parsePersonalListItem(item));
  }

  static batchParseTopListItems(cloudItems: CloudAPI_TopListItem[]): TopListItem[] {
    return cloudItems.map(item => CloudAPIEntityParser.parseTopListItem(item));
  }

  /**
   * 通用ID转换工具方法
   */
  static convertNumberIdToString(id: number): string {
    return id.toString();
  }

  static convertNumberIdsToStrings(ids: number[]): string[] {
    return ids.map(id => id.toString());
  }

  /**
   * 类型安全的转换检查方法
   */
  // static isValidCloudAPIAlbum(obj: any): obj is CloudAPI_Album {
  //   return obj && typeof obj.id === 'number' && typeof obj.name === 'string';
  // }
  //
  // static isValidCloudAPISong(obj: any): obj is CloudAPI_Song {
  //   return obj && typeof obj.id === 'number' && typeof obj.name === 'string' && Array.isArray(obj.artists);
  // }
  //
  // static isValidCloudAPIPlayList(obj: any): obj is CloudAPI_PlayList {
  //   return obj && typeof obj.id === 'number' && typeof obj.name === 'string' && obj.creator;
  // }
}
