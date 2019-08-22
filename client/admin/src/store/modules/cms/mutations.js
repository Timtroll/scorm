const mutations = {

  cms_page_title (state, data) {
    state.cms.pageTitle = data
  },

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

  cms_table_names (state, data) {
    state.cms.tableNames = data
  },

  tree_active (state, id) {
    state.cms.activeId = id
  },

  // right Panel Size
  right_panel_size (state, data) {
    state.main.rightPanelLarge = data
  },

  /**
   * cms_row
   * @param state
   */
  cms_row_request (state) {
    state.cms.row.status = 'loading'
  },

  // статус - успешно
  cms_row_success (state, data) {
    state.cms.row.status = 'success'
  },

  // статус - ошибка
  cms_row_error (state) {
    state.cms.row.status = 'error'
  },

  cms_table_row_show (state, data) {
    state.cms.row.open = data
  },

  cms_table_row_data (state, data) {
    state.cms.row.data = data
  },

  cms_add_group (state, data) {
    state.cms.addGroup.data = data
  },

  cms_show_add_group (state, data) {
    state.cms.addGroup.show = data
  },

  cms_show_add_edit_toggle (state, data) {
    state.cms.addGroup.add = data
  },

  // акшин для левой кнопки в navbar
  card_left_state (state, data) {
    state.main.leftShow = data
  }

}
export default mutations

