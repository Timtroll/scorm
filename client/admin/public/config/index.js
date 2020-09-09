export default class AppConfig {

  constructor () {
    this.title       = 'SCORM'
    this.description = 'Онлайн система обучения'
    this.lang        = 'ru'
    this.logo        = '/img/logo__bw.svg'
    this.version     = ''
    this.wssWebRTC   = 'https://scorm-rtc-multi-server.herokuapp.com:443/'
    this.wssEvent    = 'wss://freee.su/api/channel' // 'wss://freee.su/wschannel/'
    this.stunServer  = 'stun:stun.freee.su:5349'
    this.turnServer  = {
      urls:       'turn:turn.freee.su:5349',
      credential: '12345',
      username:   'brucewayne'
    }
    this.role        = null
    this.token       = null
  }

  setToken (user) {
    if (!user) return
    localStorage.setItem('token', user.token)
    localStorage.setItem('profile', JSON.stringify(user.profile))
    this.token = user.token
    this.role  = user.profile.role
  }

  removeToken () {
    localStorage.removeItem('token')
    localStorage.removeItem('profile')
    this.token = null
    this.role  = null
  }

}
