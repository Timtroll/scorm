import Api from '../Api.js'

export default {

  // получить дерево
  get_leafs (id) {
    return Api()({
      url:    'routes/get_leafs',
      method: 'post',
      params: {
        id: id
      }
    })
  },

  // Обновление / добавление
  leafs_edit (params) {
    return Api()({
      url:    'routes/edit',
      method: 'post',
      params: params
    })
  },

  // Обновление / добавление
  leafs_save (params) {
    return Api()({
      url:    'routes/save',
      method: 'post',
      params: params
    })
  },

  // удаление
  leafs_delete (id) {
    return Api()({
      url:    'routes/delete',
      method: 'post',
      params: id
    })
  }

}
