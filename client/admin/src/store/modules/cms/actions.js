import axios from 'axios'
import router from '../../../router'
import UIkit from 'uikit/dist/js/uikit.min'
import Api from './../../../api/Cms'

// Notify
const notify = (message, status = 'primary', timeout = '4000', pos = 'top-center') => {
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

  getTree ({commit}) {

    return new Promise((resolve, reject) => {
      commit('cms_request')

      Api.tree()
         .then(response => {
           const resp = response.data
           commit('cms_success', resp)
           resolve(response)
           //if (resp.status === 'ok') {}
         })
         .catch(err => {
           commit('cms_error')
           notify(err, 'danger')
           reject(err)
         })
      resolve()
    })
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
