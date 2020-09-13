import serverHttp from '@/api/serverHttp'

export default class auth {

  constructor () {
    this.profile = null
    this.token   = null
  }

  async getToken () {
    if (this.token === null) {
      this.token = localStorage.getItem('token')
    }
  }

  async deAuthorize () {
    this.profile = null
    this.token   = null
  }

  async getProfile () {
    await this.getToken()
    let result   = await this.serverHttp('auth', {
      'token': this.token
    })
    this.profile = result
    return result
  }

  async serverHttp (url, params, notifyOk, notifyFail) {
    await serverHttp.query(url, params, notifyOk, notifyFail)
  }

}
