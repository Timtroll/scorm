const getters = {

  table_status:  state => state.table.status,
  table_flat:    state => state.table.tableFlat,
  table_items:   state => state.table.items,
  table_current: state => state.table.current,

  table_api: state => state.table.api

}

export default getters

