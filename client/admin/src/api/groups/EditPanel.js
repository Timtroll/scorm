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

  // сохранение настройки
  list_save (data) {
    return Api()({
      url:    'settings/save',
      method: 'post',
      params: data
    })
  },

  list_toggle (params) {
    return Api()({
      url:    'settings/toggle',
      method: 'post',
      params: params
    })
  },


  // добавление настройки
  list_add (data) {
    return Api()({
      url:    'settings/add',
      method: 'post',
      params: data
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
  }

}
