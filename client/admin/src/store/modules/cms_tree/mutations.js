const mutations = {

  /* NAV Tree */

  set_tree (state, data) {state.items = data},

  //
  tree_active (state, id) {state.activeId = id},

  // статус
  tree_status_request (state) {state.status = 'loading'},
  tree_status_success (state, data) {state.status = 'success'},
  tree_status_error (state) {state.status = 'error'}

}
export default mutations

