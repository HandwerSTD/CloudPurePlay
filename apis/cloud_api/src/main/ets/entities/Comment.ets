interface CloudAPI_UserContent {
  avatarUrl: string
  nickname: string
  userId: number
  vipType: number
}

export interface CloudAPI_Comment {
  user: CloudAPI_UserContent
  commentId: number
  content: string
  time: number
  timeStr: string
  likedCount: number
}

interface CommentData {
  commentsTitle: string
  comments: CloudAPI_Comment[]
}

export interface CloudAPI_CommentResult {
  code: number
  data: CommentData
}

export const CommentResult_INITIAL: CloudAPI_CommentResult = {
  code: 200,
  data: {
    commentsTitle: '',
    comments: []
  }
}

export const Comment_INITIAL: CloudAPI_Comment = {
  user: {
    avatarUrl: '',
    nickname: '',
    userId: 0,
    vipType: 0
  },
  commentId: 0,
  content: '',
  time: 0,
  timeStr: '',
  likedCount: -1
}