import Api from './Api.js'

export default {

  // получить дерево
  get_list (id = 0) {
    return Api()({
      url:    'settings/get_list',
      method: 'post',
      params: id
    })
  },

  // получить прототип нового элемента
  proto_folder () {
    return Api()({
      url:    'settings/proto_folder',
      method: 'post',
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
