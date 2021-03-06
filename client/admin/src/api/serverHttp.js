import Vue         from 'vue'
import {notify}    from '@/store/methods'
import router      from '@/router'
import {appConfig} from '@/main'

let apiProxy = ''

if (!Vue.config.productionTip) {
  apiProxy = 'https://cors-c.herokuapp.com/https://freee.su' // для Localhost  https://cors-c.herokuapp.com
}
const apiUrl = apiProxy + ''

export default {

  async query (url, params, notifyOk = false, notifyFail = true, file = false) {
    const token = localStorage.getItem('token')

    if (!token) {
      appConfig.removeToken()
      router.replace({name: 'Login'}).catch(e => {})
    }
    const formData = new FormData()

    for (const [key, value] of Object.entries(params)) {
      formData.append(key, value)
    }

    const header = new Headers()
    header.append('token', token)

    if (file) {
      header.append('Content-Type', 'multipart/form-data')
    }

    const response = await fetch(apiUrl + url, {
      method:   'POST',
      mode:     'cors',
      //referrerPolicy: 'unsafe-url', // no-referrer,
      headers:  header,
      body:     formData,
      redirect: 'follow'
    })

    if (response.status === 666) {
      appConfig.removeToken()
      router.replace({name: 'Login'}).catch(e => console.log(e))
    }
    else {
      const result = await response.json()

      if (result.status === 'ok') {
        if (notifyOk) {
          notify(result.status, 'success')
        }
        console.log(
          `query: ${url}`,
          `params:   ${JSON.stringify(params)}`,
          'result', result
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
      }
    }

  }

}
