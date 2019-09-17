import Vue from 'vue'
import Vuex from 'vuex'
import auth from './modules/auth'
import main from './modules/main'
import tree from './modules/cms_tree'
//import table from './modules/cms_table'
//import editPanel from './modules/cms_editPanel'
//import settings from './modules/settings'

Vue.use(Vuex)

const store = new Vuex.Store({
  modules: {
    auth: auth,
    main: main,
    tree: tree
    //table:     table,
    //editPanel: editPanel,
    //settings:  settings
  },
  strict:  process.env.NODE_ENV !== 'production'
})

export default store
