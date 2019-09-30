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

    leaf: [
      {
        label:       'ID',
        mask:        /[^a-zA-Z-]/g,
        name:        'id',
        placeholder: '',
        readonly:    1,
        required:    1,
        add:         false,
        selected:    [],
        type:        'InputNumber',
        value:       ''
      }, {
        label:       'Родитель',
        mask:        /^\d+$/,
        name:        'parent',
        placeholder: '',
        readonly:    1,
        required:    1,
        add:         true,
        selected:    [],
        type:        'InputNumber',
        value:       ''
      }, {
        label:       'Системное имя',
        mask:        /[^a-zA-Z-]/g,
        name:        'name',
        placeholder: 'Только латинские буквы без пробелов',
        readonly:    0,
        required:    1,
        add:         true,
        selected:    [],
        type:        'InputText',
        value:       ''
      }, {
        label:       'Расшифровка',
        mask:        '',
        name:        'label',
        placeholder: '',
        readonly:    0,
        required:    1,
        add:         true,
        selected:    [],
        type:        'InputText',
        value:       ''
      }, {
        label:       'Подсказка',
        mask:        '',
        name:        'placeholder',
        placeholder: '',
        readonly:    0,
        required:    1,
        add:         true,
        selected:    [],
        type:        'InputText',
        value:       ''
      }, {
        label:       'Статус',
        mask:        /[^[0-1]+$]/g,
        name:        'status',
        placeholder: '',
        readonly:    0,
        required:    0,
        add:         true,
        selected:    [],
        type:        'InputBoolean',
        value:       1
      }, {
        label:       'Только для чтения',
        mask:        /[^[0-1]+$]/g,
        name:        'readonly',
        placeholder: '',
        readonly:    0,
        required:    0,
        add:         true,
        selected:    [],
        type:        'InputBoolean',
        value:       0
      }, {
        label:       'Можно удалять',
        mask:        /[^[0-1]+$]/g,
        name:        'removable',
        placeholder: '',
        readonly:    0,
        required:    0,
        add:         true,
        selected:    [],
        type:        'InputBoolean',
        value:       1
      }, {
        label:       'Обязательно для заполнени',
        mask:        /[^[0-1]+$]/g,
        name:        'required',
        placeholder: '',
        readonly:    0,
        required:    0,
        add:         true,
        selected:    [],
        type:        'InputBoolean',
        value:       1
      }, {
        label:       'Список значений',
        mask:        null,
        name:        'selected',
        placeholder: '',
        readonly:    0,
        required:    0,
        add:         true,
        selected:    [],
        type:        'InputSelect',
        value:       []
      }, {
        label:       'Тип поля ввода',
        mask:        '',
        name:        'type',
        placeholder: '',
        readonly:    0,
        required:    0,
        add:         true,
        selected:    [],
        type:        'InputSelect',
        value:       'InputText'
      }, {
        label:       'Значение',
        mask:        '',
        name:        'value',
        placeholder: '',
        readonly:    0,
        required:    0,
        add:         true,
        selected:    [],
        type:        'InputText',
        value:       ''
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
