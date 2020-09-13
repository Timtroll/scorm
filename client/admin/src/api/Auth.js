import Api from './Api.js'

export default {

  login (params) {
    return Api()({
      url:    'auth/login',
      method: 'post',
      params: params,
    })
  },

  //signUpPhone (params) {
  //  return Api()({
  //    url:    'user/add_by_phone',
  //    method: 'post',
  //    params: params,
  //  })
  //},

  signUp (params) {
    return Api()({
      url:    'user/registration',
      method: 'post',
      params: params,
    })
  },

  logout () {
    return Api()({
      url:    'auth/logout',
      method: 'post',
    })
  }
}
