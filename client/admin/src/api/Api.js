import Vue from 'vue'
import axios from 'axios'

//Vue.prototype.$http = axios

const token = localStorage.getItem('token')
console.log('token - ', token)

if (token) {
  axios.defaults.headers.common['Authorization'] = token
  //Vue.prototype.$http.defaults.headers.common['Access-Control-Allow-Origin'] = '*'
}

//axios.defaults.headers.common['Access-Control-Allow-Origin'] = '*'

let apiProxy
if (Vue.config.productionTip) {
  apiProxy = '' // для Localhost https://cors-anywhere.herokuapp.com/
} else {
  apiProxy = '' // Удалить, когда будет поднят https
}

const apiUrl = apiProxy + 'https://freee.su'

export default () => {
  return axios.create({
    baseURL:         apiUrl,
    crossDomain:     true,
    withCredentials: false,
    headers:         {
      //'Authorization': token,
      'Accept':        'application/json',
      'Content-Type': 'application/json'
    }
  })
}
