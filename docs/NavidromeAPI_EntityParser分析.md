# Navidrome API Entity 转换器分析报告

## 概述

本文档分析了 Navidrome API 的 Entity 与 CommonDefs 的 Entity 之间的主要区别，并提供了一个完整的转换器 `NavidromeAPI_EntityParser` 来实现两者之间的数据转换。

## 主要差异分析

### 1. Album Entity

**Navidrome Album:**
```typescript
interface Album {
  id: string;
  name: string;
  artist: string;          // 单个艺术家名
  artistId: string;        // 单个艺术家ID
  coverArt?: string;       // 封面ID
  created?: string;
  starred?: boolean;
  songCount?: number;
}
```

**CommonDefs Album:**
```typescript
interface Album {
  artists: Artist[];       // 艺术家数组
  picUrl: string;          // 图片URL
  name: string;
  id: string;
  size: number;            // 专辑大小/歌曲数量
}
```

**转换策略:**
- `artist` + `artistId` → `artists[]` (转换为数组格式)
- `coverArt` → `picUrl` (封面ID映射为图片URL)
- `songCount` → `size` (歌曲数量映射为专辑大小)

### 2. Song Entity

**Navidrome Song:**
```typescript
interface Song {
  id: string;
  name: string;
  artists: SongArtist[];   // 已经是数组格式
  album: SongAlbum;
  duration: number;        // 秒为单位
}
```

**CommonDefs Song:**
```typescript
interface Song {
  id: string;
  name: string;
  artists: Artist[];
  album: Album;
  duration: number;        // 毫秒为单位
  alias: string[];         // 别名数组
  fee: number;             // 收费信息
}
```

**转换策略:**
- `duration` 需要从秒转换为毫秒 (`* 1000`)
- 添加默认的 `alias: []` 和 `fee: 0`
- 保持 `artists` 数组格式不变

### 3. Artist Entity

**Navidrome ArtistInfo:**
```typescript
interface ArtistInfo {
  id: string;
  name: string;
  albumCount: number;
  songCount: number;
  coverArt?: string;
  artistImageUrl?: string;
}
```

**CommonDefs ArtistInfo:**
```typescript
interface ArtistInfo {
  artist: {
    briefDesc: string;     // 简介
    picUrl: string;        // 图片URL
    alias: string[];       // 别名数组
    name: string;
    id: string;
  };
  hotSongs: PlayListSong[]; // 热门歌曲
  code: number;
  more: boolean;
}
```

**转换策略:**
- 将 Navidrome 的扁平结构转换为 CommonDefs 的嵌套结构
- `coverArt` 或 `artistImageUrl` → `artist.picUrl`
- 添加默认值：`briefDesc: ''`, `alias: []`, `hotSongs: []`

### 4. PlayList Entity

**Navidrome PlayList:**
```typescript
interface PlayList {
  id: string;
  name: string;
  owner?: string;
  public?: boolean;
  songCount?: number;
  coverArt?: string;
}
```

**CommonDefs PlayList:**
```typescript
interface PlayList {
  coverImgUrl: string;
  name: string;
  id: string;
  playCount: number;       // 播放次数
  subscribedCount: number; // 订阅数
  userId: string;
  trackCount: number;      // 曲目数量
  subscribed: boolean;     // 是否已订阅
  creator: Creator;        // 创建者信息
  description: string;     // 描述
}
```

**转换策略:**
- `coverArt` → `coverImgUrl`
- `owner` → `userId` 和 `creator`
- `songCount` → `trackCount`
- 添加默认值用于 Navidrome 不支持的字段

### 5. User Entity

**Navidrome User:**
```typescript
interface User {
  id: string;
  username: string;
  email?: string;
  admin?: boolean;
}
```

**CommonDefs User:**
```typescript
interface User {
  userId: string;
  nickname: string;
  avatarUrl: string;
  signature: string;
  followeds: number;
  follows: number;
  eventCount: number;
  playlistCount: number;
  level: number;
  listenSongs: number;
  createTime: number;
  createDays: number;
}
```

**转换策略:**
- `id` → `userId`
- `username` → `nickname`
- `admin` → `level` (管理员=10, 普通用户=1)
- 为不支持的字段提供默认值

## 特殊处理情况

### 1. 时间格式转换
- Navidrome 的 `duration` 以秒为单位，CommonDefs 以毫秒为单位
- 需要 `* 1000` 转换

### 2. 数组格式转换
- Navidrome 的 `artist` (单个) → CommonDefs 的 `artists[]` (数组)
- 需要包装为数组格式

### 3. 缺失字段处理
- CommonDefs 有许多 Navidrome 不支持的字段 (如播放次数、订阅数等)
- 使用合理的默认值填充

### 4. 嵌套结构转换
- 将 Navidrome 的扁平结构转换为 CommonDefs 的嵌套结构
- 例如 ArtistInfo 的 artist 子对象

## 转换器使用方式

```typescript
import { NavidromeAPI_EntityParser } from './NavidromeAPI_EntityParser';

// 转换专辑信息
const navidromeAlbum = await NavidromeAPI_AlbumAPIUtils.getAlbumInfo(id);
const commonDefsAlbum = NavidromeAPI_EntityParser.parseAlbumInfoResult(navidromeAlbum);

// 转换歌曲搜索结果
const navidromeSongs = await NavidromeAPI_SongAPIUtils.searchSongs(keyword);
const commonDefsSongs = NavidromeAPI_EntityParser.parseSongSearchResult(navidromeSongs);

// 转换艺术家信息
const navidromeArtist = await NavidromeAPI_ArtistAPIUtils.getArtistInfo(id);
const commonDefsArtist = NavidromeAPI_EntityParser.parseArtistInfo(navidromeArtist);
```

## 已实现的转换方法

- `parseAlbum()` / `parseAlbums()`
- `parseAlbumInfoResult()`
- `parseSubAlbumResult()`
- `parseAlbumSearchResult()`
- `parseSong()` / `parseSongs()`
- `parseSongSearchResult()`
- `parseSongPlayResult()`
- `parseArtist()` / `parseArtists()`
- `parseArtistInfo()`
- `parseArtistItem()`
- `parseArtistsResult()`
- `parsePlayList()`
- `parsePlayListsResult()`
- `parsePlayListSongs()`
- `parseUser()`
- `parseLyricResult()`
- `parseTopListItem()`
- `parseLikeListToSongs()`

## 集成到 APIUtilsExports

转换器已完全集成到 `NavidromeAPI_APIUtilsExports.ets` 中，所有的 API 调用都会自动进行实体转换，确保对外提供的接口完全符合 CommonDefs 规范。

这样设计使得上层应用可以无感知地切换不同的 API 后端（CloudAPI 或 NavidromeAPI），保持了良好的抽象和一致性。
