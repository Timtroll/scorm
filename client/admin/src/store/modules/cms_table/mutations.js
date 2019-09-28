const mutations = {

  /** TABLE */
  set_table (state, data) {state.table.items = data},
  table_flat (state, data) {state.table.tableFlat = data},
  table_names (state, data) {state.table.tableNames = data},

  // статус
  table_status_request (state) {state.table.status = 'loading'},
  table_status_success (state, data) {state.table.status = 'success'},
  table_status_error (state) {state.table.status = 'error'},



}
export default mutations

