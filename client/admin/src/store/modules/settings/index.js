import actions from './actions'
import mutations from './mutations'
import getters from './getters'

const state = {

  // Шаблон редактирования с группами
  groupsEdit: {
    main:   [],
    groups: [
      {
        label:  'Основное',
        fields: []
      },
      {
        label:  'Дополнительные поля',
        fields: []
      }
    ]
  }
}

export default {
  namespaced: true,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
