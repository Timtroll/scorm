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

  // получить прототип нового элемента Leaf
  list_proto (parent) {
    return Api()({
      url:    'settings/proto_leaf',
      method: 'post',
      params: {
        parent: parent
      }
    })
  },

  // получить прототип нового элемента Foldr
  folder_proto (parent) {
    return Api()({
      url:    'settings/proto_folder',
      method: 'post',
      params: {
        parent: parent
      }
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
