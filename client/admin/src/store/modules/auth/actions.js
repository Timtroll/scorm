import axios from 'axios'
import router from '../../../router'
import UIkit from 'uikit/dist/js/uikit.min'
import Api from './../../../api/Auth'

// Notify
const notify = (message, status = 'primary', timeout = '2000', pos = 'top-center') => {
  UIkit.notification({
    message: message,
    status:  status,
    pos:     pos,
    timeout: timeout
  })
}

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
           } else {
             notify(resp.mess, 'danger')
             commit('auth_error')
             localStorage.removeItem('token')
           }
         })
         .catch(err => {
           notify(err, 'danger')
           commit('auth_request')
           reject(err)
         })

    })
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
             router.push({name: 'Login'})
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
