const getters = {

  // navbarLeftAction
  navbarLeftAction:      state => state.navbarLeftAction,
  navbarLeftActionState: state => state.navbarLeftAction.state,

  navTree: state => state.navTree.items,

  queryStatus: state => state.cms.status,

}

export default getters
