import Api_Tree                                 from '@/api/users/Tree'
import Api                                      from '@/api/users/Table'
import store                                    from '@/store/store'
import {clone, flatTree, groupedFields, notify} from '@/store/methods'
import Api_EditPanel                            from '@/api/users/EditPanel'

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
          }
          else {
            store.commit('set_tree', [])
            store.commit('tree_status_success')
            store.commit('table_status_error')
            notify('В дереве пусто', 'warning')
          }
        }

      }

    }
    catch (e) {
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

        if (resp.status === 'ok') {

          if (typeof resp['list'] !== 'undefined') {
            const table = resp.list
            store.commit('set_table', table)
            store.commit('table_status_success')
          }
          else {
            store.commit('table_status_success')
          }
        }
        else {
          notify('ERROR: ' + resp.message, 'danger')
          store.commit('table_status_error')
        }
      }

    }
    catch (e) {
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
  async leafEdit ({commit, dispatch, state}, id) {

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
        //dispatch('getTable')
      }
    }
    catch (e) {
      store.commit('editPanel_status_error') // статус - ошибка
      store.commit('editPanel_add', true)
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  },

  /**
   *
   * @param commit
   * @param dispatch
   * @param parentId
   * @returns {Promise<void>}
   */
  async leafAdd ({commit, dispatch}, parentId) {

    try {
      store.commit('card_right_show', false)
      store.commit('editPanel_folder', false)
      store.commit('editPanel_status_request') // статус - запрос
      store.commit('editPanel_data', []) // очистка данных VUEX

      const response = await Api_EditPanel.list_add(parentId)

      if (response.status !== 200) return
      const resp = await response.data
      if (resp.status === 'ok') {
        const resp = await response.data
        await dispatch('leafEdit', resp.id)
      }
      else {
        store.commit('editPanel_status_error') // статус - ошибка
        notify(resp.message, 'danger') // уведомление об ошибке
      }

    }
    catch (e) {
      store.commit('editPanel_status_error') // статус - ошибка
      store.commit('card_right_show', false)
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  },

  /**
   * Сохранить Листочек
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
      let response
      if (item.add) {
        response = await Api_EditPanel.list_add(item.fields)
      }
      else {
        response = await Api_EditPanel.list_save(item.fields)
      }

      if (response.status === 200) {

        const resp = await response.data
        if (resp.status === 'ok') {

          await dispatch('getTable', item.fields.parent)
          store.commit('card_right_show', false)
          store.commit('editPanel_data', []) // очистка данных VUEX
          store.commit('editPanel_status_success') // статус - успех
          notify(resp.status, 'success') // уведомление об ошибке

        }
        else if (resp.status === 'fail' && resp.message) {
          store.commit('editPanel_status_error') // статус - ошибка
          notify(resp.message, 'danger') // уведомление об ошибке
        }
        else {
          store.commit('editPanel_status_error') // статус - ошибка
          notify('ERROR: ' + resp.message, 'danger') // уведомление об ошибке
        }
      }
    }
    catch (e) {
      store.commit('editPanel_status_error') // статус - ошибка
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  },

  /**
   * Сохранить поле
   * @param commit
   * @param state
   * @param getters
   * @param dispatch
   * @param item
   * @returns {Promise<void>}
   */
  async leafSaveField ({commit, state, getters, dispatch}, item) {

    const parentId = item.parent
    console.log('item ---- action leafSaveField', item)

    try {
      //store.commit('editPanel_status_request') // статус - запрос

      const response = await Api_EditPanel.list_toggle(item.data)

      if (response.status === 200) {

        const resp = await response.data
        if (resp.status === 'ok') {

          dispatch('getTable', parentId)
          if (resp.message) {
            notify(resp.message, 'success') // уведомление об ошибке
          }

        }
        else {
          dispatch('getTable', parentId)
          notify('ERROR: ' + resp.message, 'danger') // уведомление об ошибке
        }
      }
    }
    catch (e) {
      dispatch('getTable', parentId)
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  },

  /**
   * удалить листочек
   * @param commit
   * @param dispatch
   * @param data
   * @returns {Promise<void>}
   */
  async removeLeaf ({dispatch}, data) {

    try {
      const response = await Api.list_delete(data.id)
      if (response.status === 200) {
        const resp = response.data
        if (resp.status === 'ok') {
          dispatch('getTable', data.parent)
          if (resp.message) {
            notify(resp.message, 'success') // уведомление об ошибке
          }
        }
        else {
          dispatch('getTable', data.parent)
          notify('ERROR: ' + resp.message, 'danger') // уведомление об ошибке
        }
      }
    }
    catch (e) {
      dispatch('getTable', data.parent)
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  }

}
export default actions
