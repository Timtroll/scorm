import actions from './actions'
import mutations from './mutations'
import getters from './getters'

const state = {

  table: {
    status:     'loading',
    current:    null,
    tableFlat:  null,
    tableNames: null,
    items:      []
  }
}

export default {
  namespaced: false,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
