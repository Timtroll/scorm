import Api from '../Api.js'

export default {

  // получить дерево
  get_leafs (id) {
    return Api()({
      url:    'settings/get_leafs',
      method: 'post',
      params: {
        id: id
      }
    })
  },

  // получить прототип нового элемента
  get_proto_leaf () {
    return Api()({
      url:    'settings/proto_leaf',
      method: 'post'
    })
  },

  // Обновление / добавление
  leafs_save (params) {
    return Api()({
      url:    'settings/save',
      method: 'post',
      params: params
    })
  },

  // удаление
  leafs_delete (id) {
    return Api()({
      url:    'settings/delete',
      method: 'post',
      params: id
    })
  }

}
