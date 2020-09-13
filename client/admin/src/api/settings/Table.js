import Api from '../Api.js'

export default {

  // получить дерево
  get_leafs (id) {
    return Api()({
      url:    'settings/get_leafs',
      params: {
        id: id
      }
    })
  },

  // Обновление / добавление
  leafs_save (params) {
    return Api()({
      url:    'settings/save',
      params: params
    })
  },

  // удаление
  leafs_delete (id) {
    return Api()({
      url:    'settings/delete',
      params: id
    })
  }

}
