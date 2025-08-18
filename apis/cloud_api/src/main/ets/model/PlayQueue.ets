import { CloudAPI_PLAYMODE } from "./Enum"
import { CloudAPI_Song } from "../entities/Song"

export interface CloudAPI_PlayQueue {
  playmode: CloudAPI_PLAYMODE
  song: CloudAPI_Song
  fileName: string
  picUrl: string
}