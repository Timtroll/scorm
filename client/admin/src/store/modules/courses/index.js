import actions   from './actions'
import mutations from './mutations'
import getters   from './getters'

const state = {

  saveRoute: null,

  list: {
    discipline: null,
    theme:      null,
    lessons:    null,
    tasks:      null
  }
}

export default {
  namespaced: true,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
