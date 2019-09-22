import Api from './Api.js'

export default {

  // получить дерево
  get_tree (id = 0) {
    return Api()({
      url:    'settings/get_tree',
      method: 'post',
      params: id
    })
  },

  // получить прототип нового элемента
  get_tree_proto () {
    return Api()({
      url:    'settings/proto_folder',
      method: 'post',
    })
  },
  

  // Обновление / добавление
  set_save (params) {
    return Api()({
      url:    'settings/save',
      method: 'post',
      params: params
    })
  },

  // удаление
  set_delete (id) {
    return Api()({
      url:    'settings/delete',
      method: 'post',
      params: id
    })
  }

}
