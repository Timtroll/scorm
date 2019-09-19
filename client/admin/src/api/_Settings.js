import Api from './Api.js'

export default {

  tree () {
    return Api()({
      url:    'settings/set',
      method: 'post'
    })
  },

  /**
   * настройки
   * @param params
   * @returns {AxiosPromise}
   */

  // добавление
  set_add (params) {
    return Api()({
      url:    'settings/set_add',
      method: 'post',
      params: params
    })
  },

  // Обновление
  set_save (params) {
    return Api()({
      url:    'settings/set_save',
      method: 'post',
      params: params
    })
  },

  // удаление
  set_delete (id) {
    return Api()({
      url:    'settings/set_delete',
      method: 'post',
      params: id
    })
  }

}
