import Api from '../Api.js'

export default {

  // получить дерево
  get_leafs (id) {
    return Api()({
      url:    'routes/',
      params: {
        parent: id
      }
    })
  },

  // Обновление / добавление
  leafs_edit (params) {
    return Api()({
      url:    'routes/edit',
      params: params
    })
  },

  // Обновление / добавление
  leafs_save (params) {
    return Api()({
      url:    'routes/save',
      params: params
    })
  },

  // удаление
  leafs_delete (id) {
    return Api()({
      url:    'routes/delete',
      params: id
    })
  }

}
