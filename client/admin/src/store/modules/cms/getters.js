const getters = {

  cardLeftState: state => state.main.leftShow,

  cardLeftAction: state => state.main.navBarLeftAction,

  pageTable: state => state.cms.table,

  Settings: state => state.cms.data,

  inputComponents: state => state.inputComponents,

  queryStatus: state => state.cms.status

}

export default getters
