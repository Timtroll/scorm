import router from './../../../router'
import {flatTree, notify} from './../../methods'
import Api from './../../../api/Table'

const actions = {

  async getTable ({commit, state}, id) {
    try {
      commit('table_status_request')

      const response = await Api.get_leafs(id)

      if (response.status === 200) {
        const resp = await response.data

        if (typeof resp['list'] !== 'undefined') {
          const table = resp.list
          commit('set_table', table)
          commit('table_status_success')
        }

      }

    } catch (e) {
      commit('table_status_error')
      notify('ERROR: ' + e, 'danger')
      throw 'ERROR: ' + e
    }

  },

  async removeTableRow ({commit, state}, id) {}

}
export default actions
