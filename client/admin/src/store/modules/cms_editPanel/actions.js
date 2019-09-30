import {notify} from './../../methods'
import Api from '../../../api/settings/EditPanel'
import store from '../../store'

const actions = {

  // получить Листочек
  async getEditPanel ({commit, state, getters}, id) {

    try {
      commit('editPanel_status_request') // статус - запрос
      commit('editPanel_data', {}) // очистка данных VUEX
      commit('editPanel_show', true) // открытие правой панели

      const response = await Api.list_edit(id)

      if (response.status === 200) {

        const resp  = await response.data
        const proto = JSON.parse(JSON.stringify(store.getters['settings/protoLeaf']))

        for (let item of proto) {
          item.value = resp.data[item.name]
        }

        commit('editPanel_data', proto) // запись данных во VUEX
        commit('editPanel_status_success') // статус - успех
      }
    } catch (e) {
      commit('editPanel_status_error') // статус - ошибка
      notify('ERROR: ' + e, 'danger') // уведомление об ошибке
      throw 'ERROR: ' + e
    }
  }

}
export default actions
