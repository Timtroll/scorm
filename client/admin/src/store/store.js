import Vue from 'vue'
import Vuex from 'vuex'
import auth from './modules/auth'

Vue.use(Vuex)

const store = new Vuex.Store({
  modules: {
    auth: auth
  },
  //strict:  process.env.NODE_ENV !== 'production'
})

export default store
