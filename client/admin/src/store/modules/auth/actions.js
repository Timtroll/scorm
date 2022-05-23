import axios       from 'axios'
import router      from '@/router'
import {notify}    from '@/store/methods'
import Api         from '@/api/Auth'
import {appConfig} from '@/main'

const actions = {

  // login
  async login ({commit, dispatch}, user) {

    try {
      commit('auth_request')
      const response = await Api.login(user)
      if (response.data.status === 'ok') {
        const user                             = response.data.data
        axios.defaults.headers.common['token'] = user.token
        appConfig.setToken(user)
        commit('auth_success', user)
        await dispatch('getGroups')
      }
      else {
        notify(response.data.message, 'danger')
        console.warn(response.data.message)
        commit('auth_error')
        appConfig.removeToken()
      }
    }
    catch (err) {
      notify(err, 'danger')
      console.error(err)
      commit('auth_error')
      //throw new Error(err)
    }

  },

  // recover password
  async recover ({commit}, email) {
    try {
      const response = await Api.recover(email)
      if (response.data.status === 'ok') {
        notify(response.message, 'success')
      }
      else {
        notify(response.data.message, 'danger')
        console.warn(response.data.message)
      }
    }
    catch (err) {
      notify(err, 'danger')
      console.error(err)
      commit('auth_error')
    }
  },

  // recover password
  async confirm ({commit}, code) {
    try {
      const response = await Api.confirm(code)
      if (response.data.status === 'ok') {
        notify(response.message, 'success')
      }
      else {
        notify(response.data.message, 'danger')
        console.warn(response.data.message)
      }
    }
    catch (err) {
      notify(err, 'danger')
      console.error(err)
      commit('auth_error')
    }
  },

  // recover password
  async newPassword ({commit}, password) {
    try {
      const response = await Api.newPassword(password)
      if (response.data.status === 'ok') {
        notify(response.message, 'success')
      }
      else {
        notify(response.data.message, 'danger')
        console.warn(response.data.message)
      }
    }
    catch (err) {
      notify(err, 'danger')
      console.error(err)
      commit('auth_error')
    }
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
          console.log(resp)
          notify(resp.message, 'danger') // уведомление об ошибке
        }
      }
    }
    catch (e) {
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  },

  // logout
  async logout ({commit}) {
    try {
      const response = await Api.logout()
      if (response.data.status === 'ok') {
        commit('logout')
        appConfig.removeToken()
        delete axios.defaults.headers.common['token']
        notify('До встречи!', 'success')
        router.replace({name: 'Login'}).catch(e => {})
      }
    }
    catch (err) {
      notify(err, 'danger')
      throw new Error(err)
    }

  },

  // logout
  async getGroups () {
    try {
      const response = await Api.getGroup()

      if (response.data.status === 'ok') {
        appConfig.setGroups(response.data.list)
      }
    }
    catch (err) {
      notify(err, 'danger')
      //throw new Error(err)
    }
  }

}
export default actions
