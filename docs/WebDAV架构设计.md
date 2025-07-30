# WebDAV

WebDAV 支持的接口：

```javascript
//获取路径下所有文件和文件夹信息
list(remotePath: string): Promise<Array<FileInfo>>

//获取文件流
get(remotePath: string): Promise<ArrayBuffer | null>

//获取文件并写入到指定路径下
writeTo(remotePath: string, filePath: string): Promise<boolean>

//上传文件到远程路径
put(remotePath: string, filePath: string): Promise<boolean>

//删除远端文件
delete(remotePath: string): Promise<boolean>

//移动远端文件
mv(sourcePath: string, targetPath: string): Promise<boolean>

//复制远端文件
cp(sourcePath: string, targetPath: string): Promise<boolean>

//创建文件夹
mkdir(remotePath: string): Promise<boolean>

//释放连接
close(): void
```

需要指定一个音乐目录（`MusicDir`），一个数据目录（`DataDir`）

## 功能设计

需要递归扫描所有的音乐，然后给每一个音乐定一个uid，然后找一个配置文件存储所有的音乐-uid对应关系，之后所有对音乐的操作都通过uid完成

歌单：采用纯文本存储，一个文件是一个歌单，每个文件里是JSON数据结构，每一个歌单有一个uid

红心歌单为不可删除的默认歌单（uid=0）

歌单存储在 `DataDir/Playlists/[UID].playlist`

心动模式就是一键播放红心歌单

私人FM就是随机整个曲库

每日推荐暂不支持

## 接口统一设计

主要的工作在于兼容云音乐的Entities和Models