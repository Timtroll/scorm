import Api from '../Api.js'

export default {

  // получить дерево
  get_tree () {
    return Api()({
      url:    'groups/',
      method: 'post'
    })
  },

  // Обновление / добавление
  save_folder (params) {
    return Api()({
      url:    'groups/save',
      method: 'post',
      params: params
    })
  },

  // Обновление / добавление
  add_folder (params) {
    return Api()({
      url:    'groups/add',
      method: 'post',
      params: params
    })
  },

  // удаление
  delete_folder (id) {
    return Api()({
      url:    'groups/delete',
      method: 'post',
      params: id
    })
  }

}
