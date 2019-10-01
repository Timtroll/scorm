import actions from './actions'
import mutations from './mutations'
import getters from './getters'

const state = {
  prototypes:{

    folder: [
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
        mask:        /[^a-zA-Z-]/g,
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
    ],

    leaf: []
  }



}

export default {
  namespaced: true,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
