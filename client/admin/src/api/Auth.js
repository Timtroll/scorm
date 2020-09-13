import Api from './Api.js'

export default {

  login (params) {
    return Api()({
      url:    'auth/login',
      params: params
    })
  },

  signUp (params) {
    return Api()({
      url:    'user/registration',
      params: params
    })
  },

  logout () {
    return Api()({
      url:    'auth/logout',
    })
  },

  // получить дерево
  getGroup () {
    return Api()({
      url:    'groups/',
    })
  },
}
