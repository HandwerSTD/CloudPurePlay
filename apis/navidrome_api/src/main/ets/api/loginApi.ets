import commonRequest from "./request/RequestUtil";
import { LogUtil } from "@pura/harmony-utils";
import { User, User_INITIAL } from "../entity/UserEntity";

/** 获取登录状态 */
interface GetUserResponse {
  user: User;
}

export const getLoginStatus = async (statePersistent?: (val: User) => void): Promise<boolean> => {
  try {
    const response = await commonRequest<GetUserResponse>({
      url: '/rest/getUser.view',
      params: { f: 'json', timestamp: new Date().getTime() }
    });

    const user = response.user;

    if (user?.username) {
      statePersistent?.(user);
      return true;
    } else {
      statePersistent?.(User_INITIAL);
      return false;
    }
  } catch (error) {
    LogUtil.error('获取登录状态失败: ', error.message);
    statePersistent?.(User_INITIAL);
    return false;
  }
};

/** 退出登录返回类型 */
interface LogOutResponse {
  status: string;
}

/** 退出登录 */
export const logOut = async (statePersistent?: (val: User) => void): Promise<boolean> => {
  try {
    const response = await commonRequest<LogOutResponse>({
      url: '/rest/logout.view',
      params: { f: 'json', timestamp: new Date().getTime() }
    });

    if (response.status === 'ok') {
      statePersistent?.(User_INITIAL);
      return true;
    } else {
      return false;
    }
  } catch (error) {
    LogUtil.error('退出登录失败: ', error.message);
    return false;
  }
};
