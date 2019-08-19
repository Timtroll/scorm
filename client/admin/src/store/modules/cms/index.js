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
      data:   null
    },
    updateRow: null
  },

  main: {
    navBarLeftAction: {
      visibility: true,
      icon:       'icon__nav.svg'
    },
    leftShow:         true,
    rightShow:        true,
    rightPanelLarge:  true
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
    {
      value: 'InputText',
      label: 'Текстовое поле'
    }, {
      value: 'InputNumber',
      label: 'Число'
    }, {
      value: 'InputTextarea',
      label: 'Текстовая область'
    }, {
      value: 'InputBoolean',
      label: 'Чекбокс'
    }, {
      value: 'InputRadio',
      label: 'Радио кнопки'
    }, {
      value: 'InputSelect',
      label: 'Выпадающий список'
    }, {
      value: 'InputDoubleList',
      label: 'Массив значений'
    }
  ]

}

export default {
  namespaced: false,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
