import Api from './Api.js'

export default {

  // получить дерево
  get_tree () {
    return Api()({
      url:    'settings/get_tree',
      method: 'post'
    })
  },

  // получить прототип нового элемента
  proto_folder () {
    return Api()({
      url:    'settings/proto_folder',
      method: 'post'
    })
  },

  // Обновление / добавление
  save_tab (params) {
    return Api()({
      url:    'settings/save_tab',
      method: 'post',
      params: params
    })
  },

  // удаление
  delete_tab (id) {
    return Api()({
      url:    'settings/delete_tab',
      method: 'post',
      params: id
    })
  }

}
