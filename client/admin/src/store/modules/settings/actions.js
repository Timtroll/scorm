import Api from '../../../api/settings/EditPanel'
import store from '../../store'
import {notify} from '../../methods'

const actions = {

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
      //commit('editPanel_show', true, {root: true}) // открытие правой панели

      const response = await Api.list_edit(id)

      if (response.status === 200) {

        const resp  = await response.data
        const proto = JSON.parse(JSON.stringify(store.getters['settings/protoLeaf']))

        for (let item of proto) {
          item.value = resp.data[item.name]
        }

        store.commit('editPanel_data', proto, {root: true}) // запись данных во VUEX
        store.commit('editPanel_status_success', {root: true}) // статус - успех
      }
    } catch (e) {
      store.commit('editPanel_status_error', {root: true}) // статус - ошибка
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
  async leafSave ({commit, state, getters}, item) {

    try {

      store.commit('editPanel_status_request') // статус - запрос

      //commit('editPanel_show', true, {root: true}) // открытие правой панели

      //const dataFromProto = await data.reduce((res, el) => ({...res, ...el}), {})

      const response = await Api.list_save(item)

      if (response.status === 200) {

        const resp = await response.data
        if (resp.status === 'ok') {

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
  }

}
export default actions
