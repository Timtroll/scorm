const getters = {

  tree:     state => state.tree.items,
  activeId: state => state.tree.activeId,
  tree_status:   state => state.tree.status,

  tree_api:   state => state.tree.api

}

export default getters

