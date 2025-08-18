# CloudAPI Entity Parser

## 简介

`CloudAPIEntityParser` 是一个专门用于将 CloudAPI 实体转换为 APIAdapter 实体的解析器类。它解决了 CloudAPI 和 APIAdapter 之间实体结构差异的问题，主要处理 ID 字段类型从 `number` 到 `string` 的转换，以及其他相关的类型转换。

## 主要功能

### 🔄 核心转换功能

- **ID类型转换**: 将CloudAPI中的`number`类型ID转换为APIAdapter中的`string`类型ID
- **嵌套实体递归转换**: 自动处理包含其他实体的复合结构
- **数组批量转换**: 支持对实体数组进行批量转换
- **类型安全**: 提供类型检查方法确保转换的安全性

### 📦 支持的实体类型

#### 音乐基础实体
- `Artist` - 歌手信息
- `Song` - 歌曲信息
- `Album` - 专辑信息
- `LocalSong` - 本地歌曲

#### 搜索结果实体
- `SongSearchResult` - 歌曲搜索结果
- `AlbumSearchResult` - 专辑搜索结果
- `PlayListSearchResult` - 歌单搜索结果
- `SearchReturn` - 通用搜索返回

#### 专辑相关实体
- `AlbumInfoResult` - 专辑详细信息
- `SubAlbumResult` - 订阅专辑结果

#### 歌单相关实体
- `PlayList` - 歌单信息
- `PlayListResult` - 歌单结果
- `PlayListsResult` - 歌单列表结果
- `PlayListOperationResult` - 歌单操作结果
- `PlayingPlayList` - 正在播放的歌单

#### 播放相关实体
- `SongPlayResult` - 歌曲播放结果
- `SongDownload` - 歌曲下载信息
- `SongDownloadItem` - 歌曲下载项
- `SongDetail` - 歌曲详细信息

#### 用户与评论实体
- `User` - 用户信息
- `Comment` - 评论信息
- `CommentResult` - 评论结果
- `Creator` - 创建者信息

#### 电台相关实体
- `DjRadio` - 电台信息
- `DjResult` - 电台结果
- `DjProgramResult` - 电台节目结果
- `DjRadioProgram` - 电台节目
- `RecommendDjRadio` - 推荐电台
- `DjRecommendResult` - 电台推荐结果
- `Dj` - DJ信息

#### 推荐相关实体
- `HeartMode` - 心动模式
- `PersonalListItem` - 个人推荐项
- `Personalized` - 个性化推荐
- `TopListItem` - 排行榜项
- `TopList` - 排行榜

#### 歌词实体
- `LyricResult` - 歌词结果

## 使用方法

### 基础转换

```typescript
import { CloudAPIEntityParser } from './CloudAPIEntityParser';

// 转换单个Album
const cloudAlbum: CloudAPI_Album = {
  artists: [{ id: 123, name: "Artist Name" }],
  picUrl: "http://example.com/pic.jpg",
  name: "Album Name",
  id: 456,
  size: 10
};

const adaptedAlbum = CloudAPIEntityParser.parseAlbum(cloudAlbum);
// 结果: { id: "456", name: "Album Name", artists: [{ id: "123", name: "Artist Name" }], ... }
```

### 批量转换

```typescript
// 批量转换Albums
const cloudAlbums: CloudAPI_Album[] = [...];
const adaptedAlbums = CloudAPIEntityParser.batchParseAlbums(cloudAlbums);

// 批量转换Songs
const cloudSongs: CloudAPI_Song[] = [...];
const adaptedSongs = CloudAPIEntityParser.batchParseSongs(cloudSongs);
```

### 复合实体转换

```typescript
// 转换专辑详情（包含歌曲列表）
const cloudAlbumInfo: CloudAPI_AlbumInfoResult = {...};
const adaptedAlbumInfo = CloudAPIEntityParser.parseAlbumInfoResult(cloudAlbumInfo);

// 转换搜索结果
const cloudSearchResult: CloudAPI_SongSearchResult = {...};
const adaptedSearchResult = CloudAPIEntityParser.parseSongSearchResult(cloudSearchResult);
```

### 类型安全转换

```typescript
// 使用类型检查确保安全转换
const unknownData: any = {...};

if (CloudAPIEntityParser.isValidCloudAPIAlbum(unknownData)) {
  const safeAlbum = CloudAPIEntityParser.parseAlbum(unknownData);
  // 安全使用转换后的数据
}
```

### 工具方法

```typescript
// ID转换工具
const stringId = CloudAPIEntityParser.convertNumberIdToString(123); // "123"
const stringIds = CloudAPIEntityParser.convertNumberIdsToStrings([1, 2, 3]); // ["1", "2", "3"]
```

## 在 CallerUtils 中的集成

```typescript
export class AlbumAPIUtils {
  static async getAlbumInfo(id: string): Promise<AlbumInfoResult> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      // 调用CloudAPI
      const cloudResult = await CloudAPI_AlbumAPIUtils.getAlbumInfo(Number.parseInt(id));
      
      // 使用Parser转换数据
      return CloudAPIEntityParser.parseAlbumInfoResult(cloudResult);
    } else {
      throw Error('API Unimplemented')
    }
  }

  static async searchAlbums(keywords: string): Promise<Album[]> {
    if (InstanceSwitcher.InstanceType === INSTANCE_TYPE.CLOUD) {
      const cloudResult = await CloudAPI_AlbumAPIUtils.searchAlbums(keywords);
      return CloudAPIEntityParser.batchParseAlbums(cloudResult);
    } else {
      throw Error('API Unimplemented')
    }
  }
}
```

## API 方法参考

### 基础实体转换方法

| 方法名 | 输入类型 | 返回类型 | 说明 |
|--------|----------|----------|------|
| `parseArtist` | `CloudAPI_Artist` | `Artist` | 转换歌手实体 |
| `parseAlbum` | `CloudAPI_Album` | `Album` | 转换专辑实体 |
| `parseSong` | `CloudAPI_Song` | `Song` | 转换歌曲实体 |
| `parsePlayList` | `CloudAPI_PlayList` | `PlayList` | 转换歌单实体 |
| `parseComment` | `CloudAPI_Comment` | `Comment` | 转换评论实体 |
| `parseUser` | `CloudAPI_User` | `User` | 转换用户实体 |

### 数组转换方法

| 方法名 | 输入类型 | 返回类型 | 说明 |
|--------|----------|----------|------|
| `parseArtists` | `CloudAPI_Artist[]` | `Artist[]` | 转换歌手数组 |
| `parseAlbums` | `CloudAPI_Album[]` | `Album[]` | 转换专辑数组 |
| `parseSongs` | `CloudAPI_Song[]` | `Song[]` | 转换歌曲数组 |
| `parsePlayLists` | `CloudAPI_PlayList[]` | `PlayList[]` | 转换歌单数组 |

### 复合实体转换方法

| 方法名 | 输入类型 | 返回类型 | 说明 |
|--------|----------|----------|------|
| `parseAlbumInfoResult` | `CloudAPI_AlbumInfoResult` | `AlbumInfoResult` | 转换专辑详情结果 |
| `parseSubAlbumResult` | `CloudAPI_SubAlbumResult` | `SubAlbumResult` | 转换订阅专辑结果 |
| `parseSongSearchResult` | `CloudAPI_SongSearchResult` | `SongSearchResult` | 转换歌曲搜索结果 |
| `parseCommentResult` | `CloudAPI_CommentResult` | `CommentResult` | 转换评论结果 |

### 批量处理方法

| 方法名 | 输入类型 | 返回类型 | 说明 |
|--------|----------|----------|------|
| `batchParseAlbums` | `CloudAPI_Album[]` | `Album[]` | 批量转换专辑 |
| `batchParseSongs` | `CloudAPI_Song[]` | `Song[]` | 批量转换歌曲 |
| `batchParseArtists` | `CloudAPI_Artist[]` | `Artist[]` | 批量转换歌手 |
| `batchParsePlayLists` | `CloudAPI_PlayList[]` | `PlayList[]` | 批量转换歌单 |

### 工具方法

| 方法名 | 输入类型 | 返回类型 | 说明 |
|--------|----------|----------|------|
| `convertNumberIdToString` | `number` | `string` | 转换单个ID |
| `convertNumberIdsToStrings` | `number[]` | `string[]` | 批量转换ID |
| `isValidCloudAPIAlbum` | `any` | `boolean` | 检查是否为有效的CloudAPI Album |
| `isValidCloudAPISong` | `any` | `boolean` | 检查是否为有效的CloudAPI Song |
| `isValidCloudAPIPlayList` | `any` | `boolean` | 检查是否为有效的CloudAPI PlayList |

## 转换规则

### 主要转换规律

1. **ID字段转换**: 所有 `number` 类型的ID字段转换为 `string` 类型
2. **嵌套实体递归转换**: 包含其他实体的字段会递归进行转换
3. **数组元素逐一转换**: 数组类型字段中的每个元素都会进行相应转换
4. **保持其他字段不变**: 除ID和嵌套实体外，其他字段保持原始值

### 特殊处理

- **用户ID**: `userId`, `commentId` 等特殊ID字段
- **专辑和歌曲关联**: 自动处理歌曲中包含的专辑信息转换
- **歌单创建者**: 自动转换歌单中的创建者信息
- **电台DJ信息**: 处理电台相关的DJ和节目信息转换

## 注意事项

1. **类型安全**: 建议在转换前使用提供的类型检查方法
2. **错误处理**: 转换过程中可能出现的数据格式错误需要在调用方处理
3. **性能考虑**: 对于大量数据的批量转换，考虑分批处理
4. **扩展性**: 新增实体类型时需要在Parser中添加对应的转换方法

## 版本信息

- **当前版本**: 1.0.0
- **兼容性**: 支持 CloudAPI 和 APIAdapter 的当前所有实体类型
- **更新日志**: 首次发布，包含所有基础实体转换功能
