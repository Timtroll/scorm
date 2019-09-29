import Api from './Api.js'

export default {

  // получить Листочек
  settings_edit (id) {
    return Api()({
      url:    'settings/edit',
      method: 'post',
      params: {
        id: id
      }
    })
  },

  // прототип Листочка
  settings_proto_leaf () {
    return Api()({
      url:    'settings/proto_leaf',
      method: 'post'
    })
  },

  // прототип Листочка
  settings_inputs () {
    return Api()({
      url:    '/settings/inputs',
      method: 'post'
    })
  },

  // добавление/сохранение настройки
  settings_save (id, data) {
    return Api()({
      url:    'settings/save',
      method: 'post',
      params: {
        id:   id,
        data: data
      }
    })
  },

  // удаление настройки
  settings_delete (id) {
    return Api()({
      url:    'settings/delete',
      method: 'post',
      params: {
        id: id
      }
    })
  },

  // включение настройки
  settings_activate (id) {
    return Api()({
      url:    'settings/activate',
      method: 'post',
      params: {
        id: id
      }
    })
  },

  // отключение настройки
  settings_hide (id) {
    return Api()({
      url:    'settings/hide',
      method: 'post',
      params: {
        id: id
      }
    })
  }

}
