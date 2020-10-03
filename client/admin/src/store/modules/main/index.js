import actions   from './actions'
import mutations from './mutations'
import getters   from './getters'

const state = {

  time: null,

  pageTitle:    '',
  pageSubTitle: '',

  navBarLeftAction: {
    visibility: true,
    icon:       'icon__nav.svg'
  },

  card: {
    leftShow:        true,
    leftNavClick:    true,
    rightShow:       false,
    rightPanelLarge: false
  },

  config: null

}

export default {
  namespaced: false,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
