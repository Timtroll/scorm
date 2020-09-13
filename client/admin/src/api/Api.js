import Vue from 'vue'
import axios from 'axios'

Vue.prototype.$http = axios
const token         = localStorage.getItem('token')

if (token) { Vue.prototype.$http.defaults.headers.common['token'] = token}
//Vue.prototype.$http.defaults.headers.common['Access-Control-Allow-Origin'] = 'https://cors-c.herokuapp.com'
//Vue.prototype.$http.defaults.headers.common['Access-Control-Allow-Origin'] = 'https://freee.su'
//Vue.prototype.$http.defaults.headers.common['Access-Control-Allow-Origin'] = 'http://localhost:8080'

let apiProxy = ''
if (Vue.config.productionTip) {
  //Vue.prototype.$http.defaults.headers.common['Access-Control-Allow-Origin'] = 'https://freee.su'
  //Vue.prototype.$http.defaults.headers.common['Access-Control-Allow-Origin'] = 'https://cors-c.herokuapp.com'
  //Vue.prototype.$http.defaults.headers.common['Access-Control-Allow-Origin'] = 'http://localhost:8080'
  //Vue.prototype.$http.defaults.headers.common['Access-Control-Allow-Credentials'] = 'true'
  apiProxy = '' // для Localhost  https://cors-c.herokuapp.com
  //apiProxy = 'https://cors-c.herokuapp.com/https://freee.su/' // для Localhost  https://cors-c.herokuapp.com
}
axios.defaults.withCredentials = true
//axios.defaults.withCredentials = !Vue.config.productionTip

const apiUrl = apiProxy + 'https://freee.su/'

const header = {

}
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
