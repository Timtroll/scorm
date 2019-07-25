import actions from './actions'
import mutations from './mutations'
import getters from './getters'

const state = {

  user: {
    status:  '',
    token:   localStorage.getItem('token') || '',
    profile: null
  }

}

export default {
  namespaced: false,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
