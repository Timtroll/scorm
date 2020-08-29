import axios    from 'axios'
import router   from '../../../router'
import {notify} from './../../methods'
import Api      from './../../../api/Auth'

const actions = {

  // login
  login ({commit}, user) {

    return new Promise((resolve, reject) => {

      commit('auth_request')

      Api.login(user)
         .then(response => {
           const resp = response.data
           if (resp.status === 'ok') {
             const token = resp.token
             localStorage.setItem('token', token)
             axios.defaults.headers.common['Authorization'] = token
             commit('auth_success', token, user)
             resolve(response)
           }
           else {
             notify(resp.mess, 'danger')
             commit('auth_error')
             localStorage.removeItem('token')
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
  async signUpPhone ({}, fields) {
    try {
      const response = await Api.signUpPhone(fields)
      if (response.status === 200) {
        const resp = await response.data
        if (resp.status === 'ok') {
          router
            .push({name: 'Login'})
            .catch(e => {})
        }
      }
    }
    catch (e) {
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  },

  // signUpEmail
  async signUpEmail ({}, fields) {
    console.log(fields)
    try {
      const response = await Api.signUpEmail(fields)
      if (response.status === 200) {
        const resp = await response.data
        if (resp.status === 'ok') {
          router
            .push({name: 'Login'})
            .catch(e => {})
        }
      }
    }
    catch (e) {
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  },

  // logout
  logout ({commit}) {

    return new Promise((resolve, reject) => {

      Api.logout()
         .then(response => {
           if (response.data.status === 'ok') {
             commit('logout')
             localStorage.removeItem('token')
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
