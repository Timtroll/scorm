import Api from '../Api.js'

export default {

  // получить дерево
  get_leafs (id) {
    return Api()({
      url:    'user/',
      params: {
        group_id: id
      }
    })
  },

  // удаление
  list_delete (id) {
    return Api()({
      url:    'user/delete',
      params: {
        id: id
      }
    })
  }

}
