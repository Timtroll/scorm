import Vue from 'vue'
import Vuex from 'vuex'

// auth
import auth from './modules/auth'

// main
import tree from './modules/cms_tree'
import table from './modules/cms_table'
import editPanel from './modules/cms_editPanel'

// pages

Vue.use(Vuex)

const store = new Vuex.Store({
  modules: {
    auth:      auth,
    tree:      tree,
    table:     table,
    editPanel: editPanel
  },
  strict:  process.env.NODE_ENV !== 'production'
})

export default store
