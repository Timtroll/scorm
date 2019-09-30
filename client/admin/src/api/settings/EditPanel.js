import Api from '../Api.js'

export default {

  // получить Листочек
  list_edit (id) {
    return Api()({
      url:    'settings/edit',
      method: 'post',
      params: {
        id: id
      }
    })
  },

  // добавление/сохранение настройки
  list_save (id, data) {
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
  list_delete (id) {
    return Api()({
      url:    'settings/delete',
      method: 'post',
      params: {
        id: id
      }
    })
  },

  // включение настройки
  list_activate (id) {
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
