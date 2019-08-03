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

const actions = {

  getNavTree ({commit}) {

  },

  getNavTreeItem ({commit}, id) {
    commit('auth_request')
  }
}
export default actions
