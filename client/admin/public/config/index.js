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
    this.profile     = null
    this.token       = null
    this.userGroups  = null
  }

  setToken (user) {
    if (!user) return
    localStorage.setItem('token', user.token)
    localStorage.setItem('profile', JSON.stringify(user.profile))
    this.token   = user.token
    this.profile = user.profile
  }

  setGroups (groups) {
    if (!groups) return
    this.userGroups = groups
    const userGroups = this._getGroups(groups, this.profile)
    localStorage.setItem('userGroups', JSON.stringify(userGroups))
  }

  removeToken () {
    localStorage.removeItem('token')
    localStorage.removeItem('profile')
    localStorage.removeItem('userGroups')
    this.token = null
    this.role  = null
  }

  _getGroups (groups, profile) {
    const userGroups    = JSON.parse(profile.groups)
    const userGroupsObj = []
    groups.forEach(i => {
      if (userGroups.includes(i.id)) {
        userGroupsObj.push(i)
      }
    })
    return userGroupsObj
  }

}
