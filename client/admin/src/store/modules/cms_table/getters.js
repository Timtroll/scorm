const getters = {

  table_status: state => state.table.status,
  table_flat:   state => state.table.tableFlat,
  table_items:  state => state.table.items,
  table_current:  state => state.table.current

  //cardLeftState: state => state.main.leftShow,
  //
  //cardLeftAction:      state => state.main.navBarLeftAction,
  //cardLeftClickAction: state => state.main.leftNavClick,
  //
  //pageTable:      state => state.cms.table, // for nav tree
  //pageTableFlat:  state => state.cms.tableFlat, // for table
  //pageTableNames: state => state.cms.tableNames,
  //
  //navActiveId: state => state.tree.activeId,
  //
  //editPanelItem:         state => state.editPanel.item,
  //pageTableAddGroupShow: state => state.editPanel.show,
  //pageTableAddEditGroup: state => state.editPanel.add,
  //
  //pageTableCurrentId: state => state.cms.activeId,
  //
  //pageTableRow:     state => state.cms.row,
  //pageTableRowShow: state => state.cms.row.open,
  //pageTableRowData: state => state.cms.row.data,
  //rightPanelSize:   state => state.main.rightPanelLarge,
  //
  //tree: state => state.tree.items,
  //
  //inputComponents: state => state.inputComponents,
  //
  //queryStatus:    state => state.cms.status,
  //queryRowStatus: state => state.cms.row.status

}

export default getters

