import { PlayListSong } from "@handwer/api_adapter";

@ObservedV2
export class WearablePlaylistSongViewModel {
  @Trace s: PlayListSong
  @Trace showMenu: boolean = false

  constructor(_s: PlayListSong) {
    this.s = _s
  }

  static fromPlaylistData(data: PlayListSong[]): WearablePlaylistSongViewModel[] {
    return data.map((item) => new WearablePlaylistSongViewModel(item));
  }
}
