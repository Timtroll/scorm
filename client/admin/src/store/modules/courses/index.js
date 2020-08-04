import actions   from './actions'
import mutations from './mutations'
import getters   from './getters'

const state = {

  listRoot: null,
  list:     null
}

export default {
  namespaced: true,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
