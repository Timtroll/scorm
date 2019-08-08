import actions from './actions'
import mutations from './mutations'
import getters from './getters'

const state = {

  navbarLeftAction: {
    visibility: true,
    state:      true,
    icon:       'icon__nav.svg'
  },

  cms: {
    status:  '',
    current: null
  },

  pageLoader: true,

  navTree: {
    state: {
      open:   false,
      status: 'loading'
    },
    items: []
  },

  table: {},

  currentRow: {},

  selectedRows: [],

  settingPage: {
    status: 'loading'
  },

  detailBar: {
    open:    false,
    status:  'loading',
    content: []
  }

}

export default {
  namespaced: false,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}