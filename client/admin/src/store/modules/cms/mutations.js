const mutations = {

  /**
   * tree
   * @param state
   */
  // статус - запрос CMS
  cms_request (state) {
    state.cms.current = null
    state.cms.status  = 'loading'
  },

  // статус - успешно
  cms_success (state, data) {
    state.cms.status = 'success'
    state.cms.data   = data
  },

  // статус - ошибка
  cms_error (state) {
    state.cms.status = 'error'
  },

  cms_table (state, data) {
    state.cms.table = data
  },

  tree_active (state, id) {
    state.cms.activeId = id
  },

  /**
   * cms_row
   * @param state
   */
  cms_row_request (state) {
    state.cms.row.status  = 'loading'
  },

  // статус - успешно
  cms_row_success (state, data) {
    state.cms.row.status = 'success'
  },

  // статус - ошибка
  cms_row_error (state) {
    state.cms.row.status = 'error'
  },

  cms_table_row (state, data) {
    state.cms.row.data = data
  },

  cms_table_update_row (state, data) {
    state.cms.updateRow = data
  },

  cms_table_row_show (state, data) {
    state.cms.row.open = data
  },

  // акшин для левой кнопки в navbar
  card_left_state (state, data) {
    state.main.leftShow = data
  }

}
export default mutations

