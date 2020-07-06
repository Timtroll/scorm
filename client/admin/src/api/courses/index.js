import Vue from 'vue'
import {notify} from '../../store/methods'

let apiProxy = ''

if (!Vue.config.productionTip) {
  apiProxy = 'https://cors-c.herokuapp.com/https://freee.su' // для Localhost  https://cors-c.herokuapp.com
}
const apiUrl = apiProxy + '/upload'

export default class files {

  constructor () {
    this.url   = apiUrl
    this.token = localStorage.getItem('token')
  }

  async load (parent) {
    const formData = new FormData()
    if (parent) {
      formData.append('parent', parent)
    }
    return await this.serverHttp('/search/', formData)
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
    } else if (result.status === 'warn') {
      if (notifyOk) {
        notify(result.message, 'warning')
      }
      return result
    } else if (result.status === 'fail') {

      notify('ERROR: ' + result.message, 'danger')
      return result
      //throw (result.message)
    }

  }

}
