
export interface NavidromeRequestContext {
  baseUrl: string; // Navidrome API 根地址
  username: string;
  password?: string; // 可选（明文登录）
  token?: string; // 可选（已生成的 token）
  salt?: string;  // 用于 Subsonic API token 生成
  apiVersion?: string; // 默认 '1.16.1'
  clientName?: string; // 客户端标识
}
