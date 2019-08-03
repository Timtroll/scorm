import actions from './actions'
import mutations from './mutations'
import getters from './getters'

const state = {

  navTree:   {
    state: {
      open:   false,
      status: 'loading',
      content:    []
    }
  },
  detailBar: {
    open:   false,
    status: 'loading',
    content:    []
  }

}

export default {
  namespaced: true,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
