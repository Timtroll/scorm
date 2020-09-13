import Api from '../Api.js'

export default {

  // получить Листочек
  list_edit (id) {
    return Api()({
      url:    'routes/edit',
      params: {
        id: id
      }
    })
  },

  // сохранение настройки
  list_save (data) {
    return Api()({
      url:    'routes/save',
      params: data
    })
  },

  list_toggle (params) {
    return Api()({
      url:    'routes/toggle',
      params: params
    })
  }
}
