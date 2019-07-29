import Api from './Api.js'

const token = localStorage.getItem('token')

export default {

  login (params) {
    return Api()({
      url:    '/login',
      method: 'post',
      params: params,
    })
  },

  logout () {

    return Api()({
      url:    '/logout',
      method: 'post',
      withCredentials: true,
      header: {
        'Authorization': token,
      }
    })
  }

}
