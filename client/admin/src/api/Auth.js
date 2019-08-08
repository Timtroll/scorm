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

  logout () {

    return Api()({
      url:    'api/logout',
      method: 'post',
    })
  }

}
