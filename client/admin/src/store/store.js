import Vue from 'vue'
import Vuex from 'vuex'
import auth from './modules/auth'
import settings from './modules/settings'
import global from './modules/global'

Vue.use(Vuex)

const store = new Vuex.Store({
  modules: {
    auth:     auth,
    global:   global,
    settings: settings
  }
  //strict:  process.env.NODE_ENV !== 'production'
})

export default store
