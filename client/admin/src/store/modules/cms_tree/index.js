import actions from './actions'
import mutations from './mutations'
import getters from './getters'

const state = {

  tree: {
    status:   'loading',
    open:     false,
    activeId: null,
    items:    [],
    itemsFlat:    []
  }

}

export default {
  namespaced: false,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
