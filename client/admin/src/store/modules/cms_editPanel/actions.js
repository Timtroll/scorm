import {notify} from './../../methods'
import Api from './../../../api/EditPanel'

const actions = {

  // получить Листочек
  async settingsLeafEdit ({commit, state}, id) {

    try {
      commit('editPanel_status_request') // статус - запрос
      commit('editPanel_data', []) // очистка данных VUEX
      commit('editPanel_show', true) // открытие правой панели

      const response = await Api.settings_edit(id)

      if (response.status === 200) {
        const resp = await response.data

        commit('editPanel_data', resp) // запись данных во VUEX
        commit('editPanel_status_success') // статус - успех
      }
    } catch (e) {
      commit('editPanel_status_error') // статус - ошибка
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  },

  // получить прототип Листочка
  async settingsLeafProto ({commit, state}, id) {

    try {
      commit('editPanel_status_request') // статус - запрос
      commit('editPanel_data', []) // очистка данных VUEX
      commit('editPanel_show', true) // открытие правой панели

      const response = await Api.settings_proto_leaf(id)

      if (response.status === 200) {
        const resp = await response.data

        commit('editPanel_data', resp) // запись данных во VUEX
        commit('editPanel_status_success') // статус - успех

      }
    } catch (e) {
      commit('editPanel_status_error') // статус - ошибка
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  },

  // получить Список типов полей ввода
  async settingsInputs ({commit, state}) {

    try {
      const response = await Api.settings_inputs()

      if (response.status === 200) {
        const resp = await response.data

        commit('editPanel_inputs', resp) // запись данных во VUEX

      }
    } catch (e) {
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  }

}
export default actions
