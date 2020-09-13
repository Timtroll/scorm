import Api from '../Api.js'

export default {

  // получить Листочек
  list_edit (id) {
    return Api()({
      url:    'settings/edit',
      params: {
        id: id
      }
    })
  },

  // сохранение настройки
  list_save (data) {
    return Api()({
      url:    'settings/save',
      params: data
    })
  },

  list_toggle (params) {
    return Api()({
      url:    'settings/toggle',
      params: params
    })
  },

  // получить прототип нового элемента Leaf
  list_proto (parent) {
    return Api()({
      url:    'settings/proto_leaf',
      params: {
        parent: parent
      }
    })
  },

  // получить прототип нового элемента Foldr
  folder_proto (parent) {
    return Api()({
      url:    'settings/proto_folder',
      params: {
        parent: parent
      }
    })
  },

  // добавление настройки
  list_add (data) {
    return Api()({
      url:    'settings/add',
      params: data
    })
  },

  // удаление настройки
  list_delete (id) {
    return Api()({
      url:    'settings/delete',
      params: {
        id: id
      }
    })
  }

}
