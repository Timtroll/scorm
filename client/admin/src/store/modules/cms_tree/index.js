import actions from './actions'
import mutations from './mutations'
import getters from './getters'

const state = {
  status:   'loading',
  open:     false,
  activeId: null,
  items:    []
}

export default {
  namespaced: true,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
