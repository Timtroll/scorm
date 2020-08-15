import Vue      from 'vue'
import {notify} from '@/store/methods'

let apiProxy = ''

if (!Vue.config.productionTip) {
  apiProxy = 'https://cors-c.herokuapp.com/https://freee.su'
}
const apiUrl = apiProxy + '/'

export default class auth {

  constructor () {
    this.url     = apiUrl
    this.profile = null
    this.token   = null
  }

  async getToken () {
    if (this.token === null) {
      this.token = localStorage.getItem('token')
    }
  }

  async deAuthorize () {
    this.profile = null
    this.token   = null
  }

  async getProfile () {
    await this.getToken()
    let result   = await this.serverHttp('auth', {
      'token': this.token
    })
    this.profile = result
    return result
  }

  async serverHttp (url, params, notifyOk = false) {
    const response = await fetch(this.url + url, {
      method:   'POST',
      body:     params,
      redirect: 'follow'
    })

    const result = await response.json()

    if (result.status === 'ok') {
      if (notifyOk) {
        notify(result.status, 'success')
      }
      return result
    }
    else if (result.status === 'warn') {
      if (notifyOk) {
        notify(result.message, 'warning')
      }
      return result
    }
    else if (result.status === 'fail') {
      notify('ERROR: ' + result.message, 'danger')
      return result
      //throw (result.message)
    }

  }

}
