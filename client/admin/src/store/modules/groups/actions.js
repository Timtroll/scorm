import Api_EditPanel from '../../../api/groups/EditPanel'
import Api_Tree from '../../../api/groups/Tree'
import store from '../../store'
import router from '../../../router'
import {clone, flatTree, notify} from '../../methods'
import Api from '../../../api/groups/Table'
import Settings from '../../../components/groups/Groups'

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

          // Добавляем folder = 0
          tree.forEach(item => item.folder = 0)

          if (tree.length > 0) {
            store.commit('set_tree', tree)
            store.commit('tree_status_success')

            //Плоское дерево
            const flattenTree = flatTree(clone(tree))
            store.commit('set_tree_flat', flattenTree)
          } else {
            store.commit('set_tree', [])
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
   * Tree folder add
   * @param commit
   * @param state
   * @param dispatch
   * @param item
   * @returns {Promise<void>}
   */
  async addFolder ({commit, state, dispatch}, item) {

    try {

      const response = await Api_Tree.add_folder(item.fields)

      if (response.status === 200) {

        const resp = await response.data
        if (resp.status === 'ok') {

          await dispatch('_updateFolder')

          notify(resp.status, 'success') // уведомление об ошибке

          await dispatch('getTree', resp.id)
          await store.commit('tree_active', resp.id)
          await router.push({
            name:   'GroupsItem',
            params: {
              id: resp.id
            }
          })

        } else {
          store.commit('editPanel_status_error') // статус - ошибка
          notify('ERROR: ' + resp.message, 'danger') // уведомление об ошибке
        }
      }

    } catch (e) {
      store.commit('editPanel_status_error')
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

      const response = await Api_Tree.save_folder(item.fields)

      if (response.status === 200) {

        const resp = await response.data
        if (resp.status === 'ok') {

          await dispatch('_updateFolder')
          notify(resp.status, 'success') // уведомление об ошибке

        } else {
          store.commit('editPanel_status_error') // статус - ошибка
          notify('ERROR: ' + resp.message, 'danger') // уведомление об ошибке
        }
      } else {
        store.commit('editPanel_status_error')
        notify('ERROR: ' + response.message, 'danger')
      }

    } catch (e) {
      store.commit('editPanel_status_error')
      notify('ERROR: ' + e, 'danger')
      throw 'ERROR: ' + e
    }
  },

  /**
   * Удалить Folder
   * @param dispatch
   * @param id
   * @returns {Promise<void>}
   */
  async removeFolder ({dispatch}, id) {
    try {
      store.commit('tree_status_request')

      const response = await Api_Tree.delete_folder({id: id})

      if (response.status === 200) {

        const resp = await response.data

        if (resp.status === 'ok') {

          // если удаляем текушую страницу, то переходим в начало раздела
          if (router.currentRoute.params.id === id) {
            await router.push({name: 'Groups'})
          }
          await dispatch('_updateFolder')
          notify(resp.status, 'success') // уведомление об успехе

        } else {
          store.commit('editPanel_status_error') // статус - ошибка
          notify(resp.message, 'danger') // уведомление об ошибке
        }

      }

    } catch (e) {
      store.commit('tree_status_error')
      notify('ERROR: ' + e, 'danger')
      throw 'ERROR: ' + e
    }
  },

  // Обновление фолдера
  _updateFolder ({dispatch}) {
    dispatch('getTree')
    store.commit('card_right_show', false)
    store.commit('editPanel_data', []) // очистка данных VUEX
    store.commit('editPanel_status_success') // статус - успех

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
          await store.commit('set_table', table)
          //await store.commit('table_status_success')
        } else {
          store.commit('table_status_error') // статус - ошибка
          notify(resp.message, 'danger') // уведомление об ошибке
        }
      }

    } catch (e) {
      store.commit('table_status_error')
      notify('ERROR: ' + e, 'danger')
      throw 'ERROR: ' + e
    }

  },

  /**
   * удалить Листочек настроек
   * @param commit
   * @param dispatch
   * @param state
   * @param item
   * @returns {Promise<void>}
   */
  async removeLeaf ({commit, dispatch, state}, item) {
    try {
      const response = await Api_EditPanel.list_delete(item.id)

      if (response.status === 200) {

        const resp = await response.data

        if (resp.status === 'ok') {

          dispatch('getTable', item.parent)

          // уведомление об успехе
          if (resp.message) {
            notify(resp.message, 'success')
          } else {
            notify(resp.status, 'success')
          }

        } else {
          // уведомление об ошибке
          if (resp.message) {
            notify(resp.message, 'danger')
          } else {
            notify(resp.status, 'danger')
          }
        }

      }
    } catch (e) {
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
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

      store.commit('card_right_show', true)
      //commit('editPanel_show', true, {root: true}) // открытие правой панели

      const response = await Api_EditPanel.list_edit(id)

      if (response.status === 200) {

        const resp  = await response.data
        const proto = clone(store.getters.editPanel_proto)

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
      let response
      if (item.add) {
        response = await Api_EditPanel.list_add(item.fields)
      } else {
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

        } else if (resp.status === 'fail' && resp.message) {
          store.commit('editPanel_status_error') // статус - ошибка
          notify(resp.message, 'danger') // уведомление об ошибке
        } else {
          store.commit('editPanel_status_error') // статус - ошибка
          notify('ERROR: ' + resp.message, 'danger') // уведомление об ошибке
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

      const response = await Api_EditPanel.list_toggle(item.data)

      if (response.status === 200) {

        const resp = await response.data
        if (resp.status === 'ok') {

          dispatch('getTable', parentId)
          if (resp.message) {
            notify(resp.message, 'success') // уведомление об ошибке
          }

        } else {
          dispatch('getTable', parentId)
          notify('ERROR: ' + resp.message, 'danger') // уведомление об ошибке
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
