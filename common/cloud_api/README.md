# CloudAPI

## 使用方式

1. 首先在应用启动时使用 ConfigUtils 注册 RequestContext（Cookie 置为空）

2. 使用 LoginAPIUtils 进行登录，拿到 Cookie 之后重新注册 RequestContext

3. 调用对应的功能 API 接口