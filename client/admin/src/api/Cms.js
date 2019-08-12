import Api from './Api.js'

const token = localStorage.getItem('token')

export default {

  tree () {
    return Api()({
      url:    'cms/set',
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
      url:    'cms/set_add',
      method: 'post',
      params: params
    })
  },

  // Обновление
  set_save (params) {
    return Api()({
      url:    'cms/set_save',
      method: 'post',
      params: params
    })
  },

  // удаление
  set_delete (params) {
    return Api()({
      url:    'cms/set_delete',
      method: 'post',
      params: params
    })
  }

}
