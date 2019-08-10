import actions from './actions'
import mutations from './mutations'
import getters from './getters'

const state = {

  cms: {
    data:     null,
    status:   '',
    current:  null,
    table:    null,
    activeId: null,
    row:      {
      open:   false,
      status: 'loading',
      data:   []

    }
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
    {label: 'Текст', value: 'InputText'},
    {label: 'Текстовая область', value: 'InputTextarea'},
    {label: 'Редактор текста', value: 'InputEditorText'},
    {label: 'Число', value: 'InputNumber'},
    {label: 'Да/Нет', value: 'InputBoolean'},
    {label: 'Радио', value: 'InputRadio'},
    {label: 'Выбор значения', value: 'InputSelect'},
    {label: 'Массив значений', value: 'InputList'},
    {label: 'Массив ключ - значение', value: 'InputDoubleList'}
  ]

}

export default {
  namespaced: false,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
