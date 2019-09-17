const mutations = {

  /* NAV Tree */

  set_tree (state, data) {state.tree.items = data},

  //
  tree_active (state, id) {state.tree.activeId = id},

  // статус
  tree_status_request (state) {state.tree.status = 'loading'},
  tree_status_success (state, data) {state.tree.status = 'success'},
  tree_status_error (state) {state.tree.status = 'error'}

}
export default mutations

