# CloudAPI

## 使用方式

1. 启动时需要使用 CloudAPIConfigUtils 注册 RequestContext（Cookie 置为空即可）

```ets
aboutToAppear(): void {
  CloudAPIConfigUtils.setRequestContext({
    baseUrl: 'http://example.com:port/',
    cookie: {},
    realIp: RealIP_INITIAL
  })
}
```

2. 使用 LoginAPIUtils 进行登录，拿到 Cookie 和用户数据之后按业务逻辑将其持久化

```ets
Button('进行二维码登录')
.onClick(async () => {
  // 获取二维码
  let str = await LoginAPIUtils.getQrCode()
  this.qrKey = str[0]; // 二维码对应的 key
  this.qrImg = str[1]; // 二维码图片链接，将其显示在 Image 里即可
})

Button('检查登录情况')
.onClick(async () => {
  const cookieSetter = (cookie: string) => {
    // 按业务逻辑需要将 cookie 持久化
  }
  const loginStatPersistent = (user: User) => {
    // 按业务逻辑需要将登录账户信息持久化
  }
  let result = await LoginAPIUtils.checkQrLogin(this.qrKey, cookieSetter, loginStatPersistent)

  promptAction.showToast({
    message: '登录' + (result ? '成功' : '失败')
  })
})
```

3. 调用对应的功能 API 接口即可