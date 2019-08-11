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
//import Settings from '../../../assets/json/settings.json'

const actions = {

  //getNavTree ({commit}, data) {
  //  commit('setNavTree', Settings.settings)
  //},

  getTree ({commit}) {

    return new Promise((resolve, reject) => {
      commit('cms_request')

      Api.tree()
         .then(response => {
           if (response.status === 200) {
             const resp = response.data

             commit('cms_success', resp.settings)

             if (typeof resp['settings'] !== 'undefined') {

               if (resp.settings.length > 0) {

                 commit('cms_table', resp.settings[0].table)
                 const firstNavItemId = resp.settings[0].id

                 router.replace({
                   name:   'SettingItem',
                   params: {
                     id: firstNavItemId
                   }
                 })
                 commit('tree_active', firstNavItemId)
               }
             }
             resolve(response)
           }
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
