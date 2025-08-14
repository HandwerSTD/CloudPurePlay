import { DailyListSongs, Cloud_RequestCookieConfig, User, User_INITIAL } from '@handwer/api_adapter'
import { PlayList } from '@handwer/api_adapter'
import { DjRadio, RecommendDjRadio } from '@handwer/api_adapter'
import { Album } from '@handwer/api_adapter'
import { TopListItem, PersonalListItem } from '@handwer/api_adapter'

@ObservedV2
class UserStore {
  @Trace user: User = User_INITIAL
  @Trace cookieSettings: Cloud_RequestCookieConfig = {}
  @Trace realIp: string = ''

  @Trace userPlaylists: PlayList[] = []
  @Trace userDjRadioList: DjRadio[] = []
  @Trace userSubAlbum: Album[] = []
  @Trace topLists: TopListItem[] = []
  @Trace personalizedList: PersonalListItem[] = []
  @Trace recommendedDj: RecommendDjRadio[] = []
  @Trace searchHistory: string[] = []
  @Trace likeList: Set<string> = new Set()

  @Trace dailySongs?: DailyListSongs

  get userId() {
    return this.user.data.profile.userId
  }
  get userNickname() {
    return this.user.data.profile.nickname
  }
}

export default new UserStore()