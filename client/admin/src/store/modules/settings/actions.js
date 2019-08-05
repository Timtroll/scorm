import axios from 'axios'
import router from '../../../router'
import UIkit from 'uikit/dist/js/uikit.min'
import Api from './../../../api/Auth'

// Notify
const notify = (message, status = 'primary', timeout = '2000', pos = 'top-center') => {
  UIkit.notification({
    message: message,
    status:  status,
    pos:     pos,
    timeout: timeout
  })
}

// fake data
import Settings from '../../../assets/json/settings.json'

const actions = {

  getNavTree ({commit}, data) {
    commit('setNavTree', Settings.settings)
  },

  getNavTreeItem ({commit}, item) {
    commit('')
  },

  removeTableRow ({commit}, row) {

  },
  editTableRow ({commit}, row) {

  }
}
export default actions
