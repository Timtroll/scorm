import Api_EditPanel from '../../../api/settings/EditPanel'
import Api_Tree from '../../../api/settings/Tree'
import store from '../../store'
import {flatTree, notify} from '../../methods'
import Api from '../../../api/settings/Table'

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
            store.commit('tree_status_error')
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

  /**
   * Tree folder save
   * @param commit
   * @param state
   * @param dispatch
   * @param item
   * @returns {Promise<void>}
   */
  async saveFolder ({commit, state, dispatch}, item) {
    try {
      store.commit('editPanel_status_request') // статус - запрос

      const response = await Api_Tree.save_tab(item)

      if (response.status === 200) {

        const resp = await response.data
        if (resp.status === 'ok') {

          dispatch('getTree', item.parent)
          store.commit('card_right_show', false)
          store.commit('editPanel_data', []) // очистка данных VUEX
          store.commit('editPanel_status_success') // статус - успех
          notify(resp.status, 'success') // уведомление об ошибке

        } else {
          store.commit('editPanel_status_error') // статус - ошибка
          notify('ERROR: ' + e, 'danger') // уведомление об ошибке
        }
      }

    } catch (e) {
      store.commit('editPanel_status_error')
      notify('ERROR: ' + e, 'danger')
      throw 'ERROR: ' + e
    }
  },

  /**
   *
   * @param dispatch
   * @param id
   * @returns {Promise<void>}
   */
  async removeFolder ({dispatch}, id) {
    try {
      store.commit('tree_status_request')

      const response = await Api_Tree.delete_tab(id)

      if (response.status === 200) {
        const resp = await response.data

        if (resp.status === 'ok') {
          dispatch('getTree')
          notify(resp.status, 'success') // уведомление об ошибке
        } else {
          notify('ERROR: ' + e, 'danger') // уведомление об ошибке
        }

      }
      const resp = await response.data

      if (typeof resp['list'] !== 'undefined') {
        const tree = resp.list

        if (tree.length > 0) {
          store.commit('set_tree', tree)
          store.commit('tree_status_success')

          //Плоское дерево
          const flattenTree = flatTree([...tree])
          store.commit('set_tree_flat', flattenTree)
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
          store.commit('table_status_success')
        }

      }

    } catch (e) {
      store.commit('table_status_error')
      notify('ERROR: ' + e, 'danger')
      throw 'ERROR: ' + e
    }

  },

  async removeTableRow ({commit, state}, id) {},

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
      store.commit('editPanel_data', {}) // очистка данных VUEX

      store.commit('card_right_show', true)
      //commit('editPanel_show', true, {root: true}) // открытие правой панели

      const response = await Api_EditPanel.list_edit(id)
      console.log(response)

      if (response.status === 200) {

        const resp  = await response.data
        const proto = JSON.parse(JSON.stringify(store.getters['settings/protoLeaf']))

        for (let item of proto) {
          item.value = resp.data[item.name]
        }

        store.commit('editPanel_data', proto) // запись данных во VUEX
        store.commit('editPanel_status_success') // статус - успех
      }
    } catch (e) {
      store.commit('editPanel_status_error') // статус - ошибка
      store.commit('card_right_show', false)
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  },

  /**
   * Сохранить Листочек настроек
   * @param commit
   * @param state
   * @param getters
   * @param id
   * @param item
   * @returns {Promise<void>}
   */
  async leafSave ({commit, state, getters, dispatch}, item) {

    try {
      store.commit('editPanel_status_request') // статус - запрос

      const response = await Api_EditPanel.list_save(item)

      if (response.status === 200) {

        const resp = await response.data
        if (resp.status === 'ok') {

          dispatch('getTable', item.parent)
          store.commit('card_right_show', false)
          store.commit('editPanel_data', []) // очистка данных VUEX
          store.commit('editPanel_status_success') // статус - успех
          notify(resp.status, 'success') // уведомление об ошибке

        } else {
          store.commit('editPanel_status_error') // статус - ошибка
          notify('ERROR: ' + e, 'danger') // уведомление об ошибке
        }
      }
    } catch (e) {
      store.commit('editPanel_status_error') // статус - ошибка
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  },

  async leafSaveField ({commit, state, getters, dispatch}, item) {

    const parentId = item.parent

    try {
      //store.commit('editPanel_status_request') // статус - запрос

      const response = await Api_EditPanel.list_save(item.data)

      if (response.status === 200) {

        const resp = await response.data
        if (resp.status === 'ok') {

          dispatch('getTable', parentId)
          if (resp.message) {
            notify(resp.message, 'success') // уведомление об ошибке
          }

        } else {
          dispatch('getTable', parentId)
          notify('ERROR: ' + e, 'danger') // уведомление об ошибке
        }
      }
    } catch (e) {
      dispatch('getTable', parentId)
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  }

}
export default actions
