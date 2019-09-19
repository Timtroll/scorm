import axios from 'axios'
import router from '../../../router'
import methods from './../../methods'
import Api from './../../../api/Auth'

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
             methods.notify(resp.mess, 'danger')
             commit('auth_error')
             localStorage.removeItem('token')
           }
         })
         .catch(err => {
           methods.notify(err, 'danger')
           commit('auth_error')
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
             methods.notify('До встречи!', 'success')
             router.push({name: 'Login'})
             resolve(response)
           }
         })
         .catch(err => {
           methods.notify(err, 'danger')
           reject(err)
         })

      resolve()
    })
  }

}
export default actions
