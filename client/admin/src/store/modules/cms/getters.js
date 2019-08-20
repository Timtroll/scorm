const getters = {

  cardLeftState: state => state.main.leftShow,

  cardLeftAction: state => state.main.navBarLeftAction,

  pageTable: state => state.cms.table,

  pageTableAddGroupData: state => state.cms.addGroup.data,
  pageTableAddGroupShow: state => state.cms.addGroup.show,
  pageTableAddEditGroup: state => state.cms.addGroup.add,

  pageTableRow:     state => state.cms.row,
  pageTableRowShow: state => state.cms.row.open,
  rightPanelSize:   state => state.main.rightPanelLarge,

  Settings: state => state.cms.data,

  inputComponents: state => state.inputComponents,

  queryStatus:    state => state.cms.status,
  queryRowStatus: state => state.cms.row.status

}

export default getters
