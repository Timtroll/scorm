import Vue from 'vue'
import axios from 'axios'

Vue.prototype.$http = axios
const token         = localStorage.getItem('token')

if (token) { Vue.prototype.$http.defaults.headers.common['token'] = token}
Vue.prototype.$http.defaults.headers.common['Access-Control-Allow-Origin'] = '*'

let apiProxy = ''
if (Vue.config.productionTip) {
  apiProxy = 'https://cors-c.herokuapp.com/https://freee.su/' // для Localhost  https://cors-c.herokuapp.com
}
axios.defaults.withCredentials = !Vue.config.productionTip

const apiUrl = apiProxy + '/'

export default () => {

  return axios.create({
    baseURL:     apiUrl,
    crossDomain: true,
    headers:     {
      'Accept':       'application/json',
      'Content-type': 'application/x-www-form-urlencoded',
      'Content-Type': 'application/json'
    }
  })
}
