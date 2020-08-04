import Vue      from 'vue'
import {notify} from '@/store/methods'

let apiProxy = ''

if (!Vue.config.productionTip) {
  apiProxy = 'https://cors-c.herokuapp.com/https://freee.su' // для Localhost  https://cors-c.herokuapp.com
}
const apiUrl = apiProxy + '/'

export default class files {

  constructor () {
    this.url   = apiUrl
    this.token = localStorage.getItem('token')
  }

  async load (route, id) {
    const formData = new FormData()
    if (id) {
      formData.append('parent', id)
    }
    return await this.serverHttp(`${route}`, formData)
  }

  async serverHttp (url, params, notifyOk = false, notifyFail = true) {
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
      console.log(
        `query: ${url}`,
        `params:   ${JSON.stringify(params)}`,
        result
      )
      return result
    }
    else if (result.status === 'warn') {
      if (notifyFail) {
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
