/** Navidrome 用户信息 */
export interface User {
  id: number;
  username: string;
  email?: string;
  admin?: boolean;
}

/** 初始值 */
export const User_INITIAL: User = {
  id: 0,
  username: '',
  email: '',
  admin: false
};
