interface Profile {
  userId:string
  nickname:string
  avatarUrl:string
  backgroundUrl:string
  gender:number
}

interface Account {
  id:string
  userName:string
  vipType:number
}

interface Data {
  account:Account
  profile:Profile
}

export interface User {
  data:Data
}

export const User_INITIAL: User = {
  data: {
    account: {
      id: "",
      userName: '',
      vipType: 0
    },
    profile: {
      userId: "",
      nickname: '',
      avatarUrl: '',
      backgroundUrl: '',
      gender: 0
    }
  }
};

