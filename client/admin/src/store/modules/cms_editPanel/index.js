import actions from './actions'
import mutations from './mutations'
import getters from './getters'

const state = {

  editPanel: {
    status: 'loading',
    group:  false,
    add:    true,
    folder: false,
    large:  false,
    item:   null,
    api: null
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
