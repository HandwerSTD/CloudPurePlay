export interface CloudAPI_Api {
  domain: string
  port: number
  user: string
  password: string
  path: string
  https: boolean
}

export const Api_INITIAL: CloudAPI_Api = {
  domain: '',
  port: 80,
  user: '',
  password: '',
  path: '',
  https: false
}