const mutations = {

  page_title (state, data) {state.main.pageTitle = data},

  /* NAV Tree */

  set_tree (state, data) {state.tree.items = data},

  //
  tree_active (state, id) {state.tree.activeId = id},

  // статус
  tree_status_request (state) {state.tree.status = 'loading'},
  tree_status_success (state, data) {state.tree.status = 'success'},
  tree_status_error (state) {state.tree.status = 'error'},

  /** TABLE */

  set_table (state, data) {state.table.items = data},

  table_flat (state, data) {state.table.tableFlat = data},

  table_names (state, data) {state.table.tableNames = data},

  // статус
  table_status_request (state) {state.table.status = 'loading'},
  table_status_success (state, data) {state.table.status = 'success'},
  table_status_error (state) {state.table.status = 'error'},

  /** RIGHT Panel */

  // статус
  editPanel_status_request (state) {state.editPanel.status = 'loading'},
  editPanel_status_success (state, data) {state.editPanel.status = 'success'},
  editPanel_status_error (state) {state.editPanel.status = 'error'},

  // right Panel Size
  editPanel_size (state, data) {
    state.editPanel.large = data
  },

  editPanel_show (state, data) {
    state.editPanel.open = data
  },

  editPanel_data (state, data) {
    state.editPanel.item = data
  },

  // акшин для левой кнопки в navbar
  card_left_state (state, data) {
    state.main.leftShow = data
  },
  card_left_nav_click (state, data) {
    state.main.leftNavClick = data
  }

}
export default mutations

