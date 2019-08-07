const mutations = {

  // статус - запрос CMS
  cms_request (state) {
    state.cms.current = null
    state.cms.status  = 'loading'
  },

  // статус - успешно
  cms_success (state, data) {
    state.cms.status  = 'success'
    state.cms.current = data
  },

  // статус - ошибка
  cms_error (state) {
    state.cms.status = 'error'
  },

  // Формирование Дерева настроек
  setNavTree (state, data) {
    state.navTree.items = data
  },

  // Формирование контента таблицы
  setTableData (state, data) {
    state.navTree.items = data
  },

  // акшин для левой кнопки в navbar
  setNavbarLeftActionState (state, data) {
    state.navbarLeftAction.state = data
  }

}
export default mutations

