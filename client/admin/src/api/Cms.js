import Api from './Api.js'

const token = localStorage.getItem('token')

export default {

  //login (params) {
  //  return Api()({
  //    url:    '/api/login',
  //    method: 'post',
  //    params: params,
  //  })
  //},

  tree () {

    return Api()({
      url:    'cms/set',
      method: 'post',
    })
  }

}
