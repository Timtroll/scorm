import Api from '../Api.js'

export default {

  // получить дерево
  get_leafs (id) {
    return Api()({
      url:    'user',
      method: 'post',
      params: {
        group: id
      }
    })
  },

  // удаление
  list_delete (id) {
    return Api()({
      url:    'user/delete',
      method: 'post',
      params: {
        id: id
      }
    })
  }

}
