import Api from '../Api.js'

export default {

  // получить Листочек
  list_edit (id) {
    return Api()({
      url:    'user/edit',
      method: 'post',
      params: {
        id: id
      }
    })
  },

  // сохранение
  list_save (data) {
    return Api()({
      url:    'user/save',
      method: 'post',
      params: data
    })
  },

  list_activate (params) {
    return Api()({
      url:    'user/activate',
      method: 'post',
      params: params
    })
  },

  list_toggle (params) {
    return Api()({
      url:    'user/toggle',
      method: 'post',
      params: params
    })
  },

  // добавление
  list_add (parent) {
    return Api()({
      url:    'user/add',
      method: 'post',
      params: {
        parent: parent
      }
    })
  }

}
