const mutations = {

  // Формирование Дерева настроек
  setNavTree (state, data) {
    state.navTree.items = data
  },

  // Формирование контента таблицы
  setTableData (state, data) {
    state.navTree.items = data
  }

}
export default mutations

