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

const actions = {

  //getNavTree ({commit}, data) {
  //  commit('setNavTree', Settings.settings)
  //},

  getTree ({commit, state}) {

    return new Promise((resolve, reject) => {
      commit('cms_request')

      Api.tree()
         .then(response => {
           if (response.status === 200) {
             const resp = response.data

             commit('cms_success', resp.settings)

             if (typeof resp['settings'] !== 'undefined') {

               const settings        = resp.settings
               const currentActiveId = state.cms.activeId

               if (settings.length > 0) {

                 commit('cms_table', settings[0].table)

                 const isActiveId   = settings.find(item => item.id === currentActiveId)
                 let firstNavItemId = settings[0].id

                 if (currentActiveId && isActiveId && isActiveId.id === currentActiveId) {
                   console.log('firstNavItemId', firstNavItemId, 'isActiveId', isActiveId.id, 'currentActiveId', currentActiveId)
                   firstNavItemId = currentActiveId
                   commit('cms_table', isActiveId.table)
                 } else {
                   commit('cms_table', settings[0].table)
                 }

                 console.log('firstNavItemId', firstNavItemId)

                 router.replace({
                   name:   'SettingItem',
                   params: {
                     id: firstNavItemId
                   }
                 }).catch(err => {})
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

  editTableRow ({commit, dispatch}, row) {
    return new Promise((resolve, reject) => {

      commit('cms_row_request')
      //console.log(typeof row.value, row.value)

      Api.set_save(row)
         .then(response => {

           if (response.status === 200) {
             const resp = response.data
             if (resp.status === 'ok') {

               commit('cms_row_success')
               commit('cms_table_row_show', false)
               dispatch('getTree')
               notify(resp.status, 'success')
               resolve(response)
             } else {
               notify(resp.message, 'danger')
               commit('cms_row_error')
             }
             //commit('cms_', resp.settings)

           }
         })
         .catch(err => {
           commit('cms_row_error')
           notify(err, 'danger')
           reject(err)
         })
      resolve()
    })
  },

  addTableRow ({commit, dispatch}, row) {
    return new Promise((resolve, reject) => {

      commit('cms_row_request')
      //console.log(typeof row.value, row.value)

      Api.set_add(row)
         .then(response => {
           if (response.status === 200) {
             const resp = response.data
             if (resp.status === 'ok') {
               commit('cms_row_success')
               commit('cms_table_row_show', false)
               dispatch('getTree')
               notify(resp.status, 'success')
               resolve(response)
             } else {
               notify(resp.message, 'danger')
               commit('cms_row_error')
             }

           }
         })
         .catch(err => {
           commit('cms_row_error')
           notify(err, 'danger')
           reject(err)
         })
      resolve()
    })
  },

  removeTableRow ({commit, dispatch}, id) {

    UIkit.modal.confirm('Удалить', {
      labels: {
        ok:     'Да',
        cancel: 'Отмена'
      }
    }).then(() => {
      return new Promise((resolve, reject) => {

        commit('cms_row_request')
        //console.log(typeof row.value, row.value)

        Api.set_delete({id: id})
           .then(response => {
             if (response.status === 200) {
               const resp = response.data
               if (resp.status === 'ok') {
                 commit('cms_row_success')
                 commit('cms_table_row_show', false)
                 dispatch('getTree')
                 notify(resp.status, 'success')
                 resolve(response)
               } else {
                 notify(resp.message, 'danger')
                 commit('cms_row_error')
               }

             }
           })
           .catch(err => {
             commit('cms_row_error')
             notify(err, 'danger')
             reject(err)
           })
        resolve()
      })
    })

  }
}
export default actions
