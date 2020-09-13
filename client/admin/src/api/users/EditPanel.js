import Api from '../Api.js'

export default {

  // получить Листочек
  list_edit (id) {
    return Api()({
      url:    'user/edit',
      params: {
        id: id
      }
    })
  },

  // сохранение
  list_save (data) {
    return Api()({
      url:    'user/save',
      params: data
    })
  },

  list_activate (params) {
    return Api()({
      url:    'user/activate',
      params: params
    })
  },

  list_toggle (params) {
    return Api()({
      url:    'user/toggle',
      params: params
    })
  },

  // добавление
  list_add (parent) {
    return Api()({
      url:    'user/add',
      params: {
        parent: parent
      }
    })
  }

}
