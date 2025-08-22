import { PlayListSong } from "@handwer/api_adapter";

@ObservedV2
export class PlaylistSongViewModel {
  @Trace s: PlayListSong
  @Trace showMenu: boolean = false

  constructor(_s: PlayListSong) {
    this.s = _s
  }

  static fromPlaylistData(data: PlayListSong[]): PlaylistSongViewModel[] {
		return data.map((item) => new PlaylistSongViewModel(item));
	}
}