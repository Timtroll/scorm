import Api_Tree from '../../../api/users/Tree'
import Api from '../../../api/users/Table'
import store from '../../store'
import {clone, flatTree, groupedFields, notify} from '../../methods'
import Api_EditPanel from '../../../api/users/EditPanel'

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

  },

  // ***************************************
  // LEAF
  // ***************************************

  /**
   * получить Листочек настроек
   * @param commit
   * @param state
   * @param getters
   * @param id
   * @returns {Promise<void>}
   */
  async leafEdit ({commit, state, getters}, id) {

    try {
      store.commit('editPanel_status_request') // статус - запрос
      store.commit('editPanel_data', []) // очистка данных VUEX
      store.commit('card_right_show', false) // открытие правой панели

      const response = await Api_EditPanel.list_edit(id)

      if (response.status === 200) {

        const resp  = await response.data
        const proto = clone(store.getters.editPanel_proto)

        //const groups =_groupedFields({})
        const groups = groupedFields(resp.data, proto)

        store.commit('editPanel_data', groups) // запись данных во VUEX
        store.commit('editPanel_status_success') // статус - успех
        store.commit('card_right_show', true) // открытие правой панели
      }
    } catch (e) {
      store.commit('editPanel_status_error') // статус - ошибка
      store.commit('editPanel_add', true)
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  },

  async leafProto ({commit, state, getters}, parentId) {

    try {
      store.commit('card_right_show', false)
      store.commit('card_right_show', false)
      store.commit('editPanel_folder', false)
      store.commit('editPanel_status_request') // статус - запрос
      store.commit('editPanel_data', []) // очистка данных VUEX

      const response = await Api_EditPanel.list_proto(parentId)

      if (response.status !== 200) return

      const resp  = await response.data
      const proto = clone(store.getters.editPanel_proto)

      //const groups =_groupedFields({})
      const groups = groupedFields(resp.data, proto)

      store.commit('editPanel_data', groups) // запись данных во VUEX
      store.commit('editPanel_status_success') // статус - успех

      store.commit('card_right_show', true) // открытие правой панели

    } catch (e) {
      store.commit('editPanel_status_error') // статус - ошибка
      store.commit('card_right_show', false)
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  }

}
export default actions
