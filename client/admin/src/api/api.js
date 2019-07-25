import Vue from 'vue'
import axios from 'axios'
import UIkit from 'uikit/dist/js/uikit.min'

const notify = (message, status = 'primary', timeout = '2000', pos = 'top-center') => {
  UIkit.notification({
    message: message,
    status:  status,
    pos:     pos,
    timeout: timeout
  })
}

// api
axios.defaults.headers.common['Access-Control-Allow-Origin'] = '*'

let apiProxy
if (Vue.config.productionTip) {
  apiProxy = 'https://cors-anywhere.herokuapp.com/'
} else {
  apiProxy = 'https://cors-anywhere.herokuapp.com/' // Удалить, когда будет поднят https
}

const apiUrl = apiProxy + 'http://freee.su/'

const api = {
  logIn:  apiUrl + 'login',
  logOut: apiUrl + 'logout'
}
