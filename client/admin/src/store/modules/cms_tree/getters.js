const getters = {

  tree:     state => state.tree.items,
  treeFlat:     state => state.tree.itemsFlat,
  activeId: state => state.tree.activeId,
  tree_status:   state => state.tree.status,

  tree_proto: state => state.tree.proto,

  tree_api:   state => state.tree.api

}

export default getters

