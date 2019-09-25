import router from './../../../router'
import methods from './../../methods'
import Api from './../../../api/Table'
//import UIkit from 'uikit/dist/js/uikit.min'

const actions = {

  getTable ({commit, state}, id) {
    const table = require('../../../assets/mock/Table.json')

    commit('set_table', table)

  }

}
export default actions
