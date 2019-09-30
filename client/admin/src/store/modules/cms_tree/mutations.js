const mutations = {

  /* NAV Tree */

  set_tree (state, data) {state.tree.items = data},
  set_tree_flat (state, data) {state.tree.itemsFlat = data},

  // Active tree item
  tree_active (state, id) {state.tree.activeId = id},

  // статус
  tree_status_request (state) {state.tree.status = 'loading'},
  tree_status_success (state, data) {state.tree.status = 'success'},
  tree_status_error (state) {state.tree.status = 'error'},

  // api
  tree_api (state, data) {state.tree.api = data}

}
export default mutations

