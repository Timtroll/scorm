import Api_Tree from '../../../api/users/Tree'
import Api from '../../../api/users/Table'
import store from '../../store'
import {clone, flatTree, groupedFields, notify} from '../../methods'

const actions = {

  // ***************************************
  // TREE
  // ***************************************

  /**
   * Дерево категорий
   * @param commit
   * @param state
   * @returns {Promise<void>}
   */
  async getTree ({commit, state}) {
    try {
      store.commit('tree_status_request')

      const response = await Api_Tree.get_tree()
      //const routeId  = router.currentRoute.params.id

      if (response.status === 200) {
        const resp = await response.data

        if (typeof resp['list'] !== 'undefined') {
          const tree = resp.list

          if (tree.length > 0) {
            store.commit('set_tree', tree)
            store.commit('tree_status_success')

            //Плоское дерево
            const flattenTree = flatTree([...tree])
            store.commit('set_tree_flat', flattenTree)
          } else {
            store.commit('set_tree', [])
            store.commit('tree_status_success')
            store.commit('table_status_error')
            notify('В дереве пусто', 'warning')
          }
        }

      }

    } catch (e) {
      store.commit('tree_status_error')
      notify('ERROR: ' + e, 'danger')
      throw 'ERROR: ' + e
    }
  },


  // ***************************************
  // TABLE
  // ***************************************
  async getTable ({commit, state}, id) {

    try {
      store.commit('table_status_request')

      const response = await Api.get_leafs(id)

      if (response.status === 200) {
        const resp = await response.data

        if (typeof resp['list'] !== 'undefined') {
          const table = resp.list
          store.commit('set_table', table)
          //store.commit('table_status_success')
        }
      }

    } catch (e) {
      store.commit('table_status_error')
      notify('ERROR: ' + e, 'danger')
      throw 'ERROR: ' + e
    }

  }

}
export default actions
