import Vue from 'vue'
import axios from 'axios'

Vue.prototype.$http = axios

const token = localStorage.getItem('token')
console.log('token - ', token)

if (token) {
  Vue.prototype.$http.defaults.headers.common['Authorization']               = token
  Vue.prototype.$http.defaults.headers.common['Access-Control-Allow-Origin'] = '*'
}

let apiProxy = ''
if (Vue.config.productionTip) {
  apiProxy = 'https://cors-c.herokuapp.com/' // для Localhost  https://cors-c.herokuapp.com
}

const apiUrl = apiProxy + 'https://freee.su'

export default () => {
  return axios.create({
    baseURL:         apiUrl,
    crossDomain:     true,
    withCredentials: false,
    headers:         {
      'Accept':       'application/json',
      'Content-type': 'application/x-www-form-urlencoded'
      //'Content-Type':  'application/json'
    }
  })
}
