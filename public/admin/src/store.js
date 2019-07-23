import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state:     {
    user: {
      isAuthorised: false
    }

  },
  mutations: {
    setAuth (state, payload) {state.user.isAuthorised = payload}
  },
  actions:   {
    //setAuthorised ({commit, stat}) {},
    setAuth ({dispatch}, payload) {
      dispatch('setAuth', payload)
      sessionStorage.setItem('auth', 'true')
    }

  }
})
export default {
  state,
  getters,
  actions,
  mutations,
}
