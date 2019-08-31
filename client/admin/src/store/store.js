import Vue from 'vue'
import Vuex from 'vuex'
import auth from './modules/auth'
import cms from './modules/settings'

Vue.use(Vuex)

const store = new Vuex.Store({
  modules: {
    auth: auth,
    cms:  cms
  },
  strict:  process.env.NODE_ENV !== 'production'
})

export default store
