import Api from '../Api.js'

export default {

  // получить дерево
  get_tree () {
    return Api()({
      url:    'groups/',
    })
  },

  // Обновление / добавление
  save_folder (params) {
    return Api()({
      url:    'groups/save',
      params: params
    })
  },

  // Обновление / добавление
  edit_folder (id) {
    return Api()({
      url:    'groups/edit',
      params: id
    })
  },

  // Обновление / добавление
  add_folder (params) {
    return Api()({
      url:    'groups/add',
      params: params
    })
  },

  // удаление
  delete_folder (id) {
    return Api()({
      url:    'groups/delete',
      params: id
    })
  }

}
