import actions from './actions'
import mutations from './mutations'
import getters from './getters'

const state = {

  navbarLeftAction: {
    visibility: true,
    state:      true,
    icon:       'icon__nav.svg'
  },

  pageLoader: true

}

export default {
  namespaced: false,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
