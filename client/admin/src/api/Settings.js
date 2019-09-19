import Api from './Api.js'

export default {

  get_tree (id = 0) {
    return Api()({
      url:    'settings/get_tree',
      method: 'post',
      params: id
    })
  },

  /**
   * настройки
   * @param params
   * @returns {AxiosPromise}
   */

  // добавление
  //set_add (params) {
  //  return Api()({
  //    url:    'cms/set_add',
  //    method: 'post',
  //    params: params
  //  })
  //},

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
