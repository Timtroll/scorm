import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'
import router from './router'
import UIkit from 'uikit/dist/js/uikit.min'

let notify = (message, status = 'primary', timeout = '2000', pos = 'top-center') => {
  UIkit.notification({
    message: message,
    status:  status,
    pos:     pos,
    timeout: timeout
  })
}

Vue.use(Vuex)

// api
axios.defaults.headers.common['Access-Control-Allow-Origin'] = '*'

let apiProxy
if (Vue.config.productionTip) {
  apiProxy = 'https://cors-anywhere.herokuapp.com/'
} else {
  apiProxy = ''
}

const apiUrl = apiProxy + 'http://freee.su/'

const api = {
  logIn:  apiUrl + 'login',
  logOut: apiUrl + 'logout'
}

export default new Vuex.Store({

  state: {
    user: {
      status:  '',
      token:   localStorage.getItem('token') || '',
      profile: null
    }

  },

  mutations: {

    // статус - запрос авторизации
    auth_request (state) {
      state.user.status = 'loading'
    },

    // статус - успешная авторизация
    auth_success (state, token, user) {
      state.user.status = 'success'
      state.user.token  = token
      state.user.user   = user
    },

    // статус - ошибка авторизации
    auth_error (state) {
      state.user.status = 'error'
    },

    logout (state) {
      state.user.status = ''
      state.user.token  = ''
    }
  },

  actions: {

    // login
    login ({commit}, user) {
      return new Promise((resolve, reject) => {

        commit('auth_request')

        axios(api.logIn, {
          params:          user,
          method:          'POST',
          crossDomain:     true,
          withCredentials: false
        })
          .then(response => {

            const resp = response.data

            if (resp.status === 'ok') {
              console.log(resp)
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
        axios(api.logOut, {
          method:          'POST',
          crossDomain:     true,
          withCredentials: false
        })
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
  },
  getters: {

    isLoggedIn: state => !!state.user.token,
    authStatus: state => state.user.status
  }
})
