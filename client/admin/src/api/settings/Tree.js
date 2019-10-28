import Api from '../Api.js'

export default {

  // получить дерево
  get_tree () {
    return Api()({
      url:    'settings/get_tree',
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
      url:    'settings/delete',
      method: 'post',
      params: id
    })
  }

}
