import Api from './Api.js'

const token = localStorage.getItem('token')

export default {

  login (params) {
    return Api()({
      url:    'api/login',
      method: 'post',
      params: params,
    })
  },

  signUpPhone (params) {
    return Api()({
      url:    'user/add_by_phone',
      method: 'post',
      params: params,
    })
  },

  signUpEmail (params) {
    return Api()({
      url:    'user/add_by_email',
      method: 'post',
      params: params,
    })
  },

  logout () {
    return Api()({
      url:    'api/logout',
      method: 'post',
    })
  }
}
