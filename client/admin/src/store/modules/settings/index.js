import actions from './actions'
import mutations from './mutations'
import getters from './getters'

const state = {

  protoFolder: [
    {
      label:       'Родитель',
      mask:        '',
      name:        'parent',
      placeholder: '',
      readonly:    0,
      required:    1,
      selected:    [],
      type:        'InputNumber',
      value:       ''
    },
    {
      label:       'Имя',
      mask:        '',
      name:        'label',
      placeholder: '',
      readonly:    0,
      required:    1,
      selected:    [],
      type:        'InputText',
      value:       ''
    },
    {
      label:       'Системное имя',
      mask:        '',
      name:        'name',
      placeholder: '',
      readonly:    0,
      required:    1,
      selected:    [],
      type:        'InputText',
      value:       ''
    },
    {
      label:       'Статус',
      mask:        '',
      name:        'status',
      placeholder: '',
      readonly:    0,
      required:    0,
      selected:    [],
      type:        'InputBoolean',
      value:       ''
    }
  ]

}

export default {
  namespaced: true,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
