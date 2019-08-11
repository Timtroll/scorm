import actions from './actions'
import mutations from './mutations'
import getters from './getters'

const state = {

  cms: {
    data:      null,
    status:    '',
    current:   null,
    table:     null,
    activeId:  null,
    row:       {
      open:   false,
      status: 'loading',
      data:   []
    },
    updateRow: null
  },

  main: {
    navBarLeftAction: {
      visibility: true,
      icon:       'icon__nav.svg'
    },
    leftShow:         true,
    rightShow:        true
  },

  pageLoader: true,

  navTree: {
    state: {
      open:   false,
      status: 'loading'
    },
    items: null
  },

  inputComponents: [
    'InputText',
    'InputTextarea',
    'InputNumber',
    'InputBoolean',
    'InputRadio',
    'InputSelect',
    'InputList',
    'InputDoubleList'
  ]

}

export default {
  namespaced: false,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
