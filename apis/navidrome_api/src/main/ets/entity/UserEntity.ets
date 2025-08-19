/** Navidrome 用户信息 */
export interface User {
  username: string;
  email?: string;
  admin?: boolean;
}

/** 初始值 */
export const User_INITIAL: User = {
  username: '',
  email: '',
  admin: false
};
