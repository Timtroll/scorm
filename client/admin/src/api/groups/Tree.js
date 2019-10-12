import Api from '../Api.js'

export default {

  // получить дерево
  get_tree () {
    return Api()({
      url:    'groups',
      method: 'post'
    })
  },

  // Обновление / добавление
  save_folder (params) {
    return Api()({
      url:    'settings/save_folder',
      method: 'post',
      params: params
    })
  },

  // Обновление / добавление
  add_folder (params) {
    return Api()({
      url:    'settings/add_folder',
      method: 'post',
      params: params
    })
  },

  // удаление
  delete_folder (id) {
    return Api()({
      url:    'settings/delete_folder',
      method: 'post',
      params: id
    })
  }

}
