import actions from './actions'
import mutations from './mutations'
import getters from './getters'

const state = {

  editPanel:       {
    status: 'loading',
    //open:   false,
    group:  false,
    add:    true,
    large:  false,
    item:   null
  },

  inputComponents: []

}

export default {
  namespaced: false,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
