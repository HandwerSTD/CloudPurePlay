import { Song } from "./Song"

export interface SearchReturn {
  list: Array<Song>
  hasMore: boolean
  songCount: number
}