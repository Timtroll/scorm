import Vue         from 'vue'
import axios       from 'axios'
import {appConfig} from '@/main'
import router      from '@/router'

Vue.prototype.$http = axios
const token         = localStorage.getItem('token')

if (token) {
  Vue.prototype.$http.defaults.headers.common['token'] = token
}
//else {
//  appConfig.removeToken()
//  router.push({name: 'Login'}).catch(e => {})
//}

let apiProxy = ''
if (Vue.config.productionTip) {
  apiProxy = 'https://cors-c.herokuapp.com/https://freee.su/' // для Localhost  https://cors-c.herokuapp.com
}
axios.defaults.withCredentials = false
//axios.defaults.withCredentials = !Vue.config.productionTip

const apiUrl = apiProxy + '/'

export default () => {

  return axios.create({
    baseURL: apiUrl,
    method:  'post',
    //crossDomain: true,
    headers: {
      'Accept':       'application/json',
      'Content-type': 'application/x-www-form-urlencoded',
      'Content-Type': 'application/json'
    },

    //transformRequest:  [(data, headers) => data],
    //transformResponse: [(data) => data],

    onUploadProgress: (progressEvent) => {
      // Do whatever you want with the native progress event
    },

    // `onDownloadProgress` allows handling of progress events for downloads
    onDownloadProgress: (progressEvent) => {
      // Do whatever you want with the native progress event
    },

    validateStatus: function (status) {
      if (status === 666) {
        router.replace({name: 'Login'}).then()
        return status
      }
      else {
        return status
      }
    }
  })
}
