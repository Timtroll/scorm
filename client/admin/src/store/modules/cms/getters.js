const getters = {

  cardLeftState: state => state.main.leftShow,

  cardLeftAction:      state => state.main.navBarLeftAction,
  cardLeftClickAction: state => state.main.leftNavClick,

  pageTable:      state => state.cms.table,
  pageTableNames: state => state.cms.tableNames,

  pageTableAddGroupData: state => state.cms.addGroup.data,
  pageTableAddGroupShow: state => state.cms.addGroup.show,
  pageTableAddEditGroup: state => state.cms.addGroup.add,

  pageTableCurrentId: state => state.cms.activeId,

  pageTableRow:     state => state.cms.row,
  pageTableRowShow: state => state.cms.row.open,
  rightPanelSize:   state => state.main.rightPanelLarge,

  Settings: state => state.cms.data,

  inputComponents: state => state.inputComponents,

  queryStatus:    state => state.cms.status,
  queryRowStatus: state => state.cms.row.status

}

export default getters
