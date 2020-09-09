import axios    from 'axios'
import router   from '@/router'
import {notify} from '@/store/methods'
import Api      from '@/api/Auth'
import {appConfig}      from '@/main'

const actions = {

  // login
  login ({commit}, user) {

    return new Promise((resolve, reject) => {

      commit('auth_request')

      Api.login(user)
         .then(response => {
           const resp = response.data
           if (resp.status === 'ok') {
             const user = resp.data
             appConfig.setToken(user)
             axios.defaults.headers.common['Authorization'] = user.token
             commit('auth_success', user)
             resolve(response)
           }
           else {
             notify(resp.mess, 'danger')
             commit('auth_error')
             appConfig.removeToken()
           }
         })
         .catch(err => {
           notify(err, 'danger')
           commit('auth_error')
           reject(err)
         })

    })
  },

  // signUpPhone
  async signUp ({}, fields) {
    try {
      const response = await Api.signUp(fields)
      if (response.status === 200) {
        const resp = await response.data
        if (resp.status === 'ok') {
          router
            .push({name: 'Login'})
            .catch(e => {})
        }
        else {
          notify(resp.message, 'danger') // уведомление об ошибке
        }
      }
    }
    catch (e) {
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  },

  // signUpEmail
  //async signUpEmail ({}, fields) {
  //  console.log(fields)
  //  try {
  //    const response = await Api.signUpEmail(fields)
  //    if (response.status === 200) {
  //      const resp = await response.data
  //      if (resp.status === 'ok') {
  //        router
  //          .push({name: 'Login'})
  //          .catch(e => {})
  //      }
  //    }
  //  }
  //  catch (e) {
  //    notify('ERROR: ' + e, 'danger') // уведомление об ошибке
  //    throw 'ERROR: ' + e
  //  }
  //},

  // logout
  logout ({commit}) {

    return new Promise((resolve, reject) => {

      Api.logout()
         .then(response => {
           if (response.data.status === 'ok') {
             commit('logout')
             appConfig.removeToken()
             delete axios.defaults.headers.common['Authorization']
             notify('До встречи!', 'success')
             router.push({name: 'Login'}).catch(e => {})
             resolve(response)
           }
         })
         .catch(err => {
           notify(err, 'danger')
           reject(err)
         })

      resolve()
    })
  }

}
export default actions
