import actions from './actions'
import mutations from './mutations'
import getters from './getters'

const state = {

  cms: {
    data:       null,
    status:     '',
    current:    null,
    table:      null,
    tableFlat:  null,
    tableNames: null,
    activeId:   null,
    row:        {
      open:   false,
      status: 'loading',
      data:   null
    },
    addGroup:   {
      show: false,
      add:  true,
      data: {}
    },
    updateRow:  null
  },

  main: {
    navBarLeftAction: {
      visibility: true,
      icon:       'icon__nav.svg'
    },
    leftShow:         true,
    leftNavClick:     true,
    rightShow:        true,
    rightPanelLarge:  false
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
      value: 'inputDateTime',
      label: 'Дата и время'
    }, {
      value: 'InputTextarea',
      label: 'Текстовая область'
    }, {
      value: 'InputCKEditor',
      label: 'Текстовый редактор - CKEditor'
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
    }, {
      value: 'InputCode',
      label: 'Редактор кода'
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
