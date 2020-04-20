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

  // получить прототип нового элемента Leaf
  list_proto (parent) {
    return Api()({
      url:    'user/proto_leaf',
      method: 'post',
      params: {
        parent: parent
      }
    })
  },

  // добавление настройки
  list_add (data) {
    return Api()({
      url:    'user/add',
      method: 'post',
      params: data
    })
  }

}
