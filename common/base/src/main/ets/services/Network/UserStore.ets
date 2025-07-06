import { RequestCookieConfig, User, User_INITIAL } from '@handwer/cloud_api'
import { PlayList } from '@handwer/cloud_api'
import { DjRadio, RecommendDjRadio } from '@handwer/cloud_api'
import { Album } from '@handwer/cloud_api'
import { TopListItem, PersonalListItem } from '@handwer/cloud_api'

@ObservedV2
class UserStore {
  @Trace user: User = User_INITIAL
  @Trace cookieSettings: RequestCookieConfig = {}
  @Trace realIp: string = ''

  @Trace userPlaylists: PlayList[] = []
  @Trace userDjRadioList: DjRadio[] = []
  @Trace userSubAlbum: Album[] = []
  @Trace topLists: TopListItem[] = []
  @Trace personalizedList: PersonalListItem[] = []
  @Trace recommendedDj: RecommendDjRadio[] = []
  @Trace searchHistory: string[] = []
  @Trace likeList: Set<string> = new Set()
}

export default new UserStore()