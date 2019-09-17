import router from './../../../router'
import methods from './../../methods'
import UIkit from 'uikit/dist/js/uikit.min'
import Api from './../../../api/Settings'


const actions = {

  //getNavTree ({commit}, data) {
  //  commit('setNavTree', Settings.settings)
  //},

  getTree ({commit, state}) {
    return new Promise((resolve, reject) => {
      commit('cms_request')

      Api.get_tree()
         .then(response => {
           if (response.status === 200) {

             const resp = response.data
             commit('cms_success', resp.settings)

             if (typeof resp['settings'] !== 'undefined') {

               const settings = resp.settings
               const routeId  = router.currentRoute.params.id

               if (settings.length > 0) {

                 // массив всех таблиц
                 const tableData = methods.flat([...settings])

                 commit('cms_table_flat', tableData)

                 // set active table == router.params.id
                 if (router.currentRoute.params.id) {

                   const currentPageTable = [...tableData].find(i => i.id === Number(routeId))

                   commit('cms_table_row_show', false)
                   commit('cms_show_add_group', false)
                   commit('tree_active', routeId)
                   if (currentPageTable.table) {
                     commit('cms_table', currentPageTable.table)
                   }

                   commit('cms_table_names', currentPageTable.label)

                 }

               }
             }
             resolve(response)
           }
         })
         .catch(err => {
           commit('cms_error')
           methods.notify('ERROR: ' + err, 'danger')
           //reject(err)
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
               methods.notify(resp.status, 'success')
               resolve(response)
             } else {
               methods.notify(resp.message, 'danger')
               commit('cms_row_error')
             }
             //commit('cms_', resp.settings)

           }
         })
         .catch(err => {
           commit('cms_row_error')
           methods.notify(err, 'danger')
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
               methods.notify(resp.status, 'success')
               resolve(response)
             } else {
               methods.notify(resp.message, 'danger')
               commit('cms_row_error')
             }

           }
         })
         .catch(err => {
           commit('cms_row_error')
           methods.notify(err, 'danger')
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
                 methods.notify(resp.status, 'success')
                 resolve(response)
               } else {
                 methods.notify(resp.message, 'danger')
                 commit('cms_row_error')
               }

             }
           })
           .catch(err => {
             commit('cms_row_error')
             methods.notify(err, 'danger')
             reject(err)
           })
        resolve()
      })
    })

  },

  /////// Group

  /**
   *  ADD GROUP
   * @param commit
   * @param dispatch
   * @param row
   * @returns {Promise<unknown>}
   */
  addGroup ({commit, dispatch}, row) {
    return new Promise((resolve, reject) => {

      commit('cms_row_request')

      Api.set_add(row)
         .then(response => {
           if (response.status === 200) {
             const resp = response.data
             if (resp.status === 'ok') {
               commit('cms_row_success')
               commit('cms_show_add_group', false)
               dispatch('getTree')
               methods.notify(resp.status, 'success')
               resolve(response)
             } else {
               methods.notify(resp.message, 'danger')
               commit('cms_row_error')
             }

           }
         })
         .catch(err => {
           commit('cms_row_error')
           methods.notify(err, 'danger')
           reject(err)
         })
      resolve()
    })
  },

  editGroup ({commit, dispatch}, row) {
    return new Promise((resolve, reject) => {

      commit('cms_row_request')

      Api.set_save(row)
         .then(response => {
           if (response.status === 200) {
             const resp = response.data
             if (resp.status === 'ok') {
               commit('cms_row_success')
               commit('cms_show_add_group', false)
               dispatch('getTree')
               methods.notify(resp.status, 'success')
               resolve(response)
             } else {
               methods.notify(resp.message, 'danger')
               commit('cms_row_error')
             }

           }
         })
         .catch(err => {
           commit('cms_row_error')
           methods.notify(err, 'danger')
           reject(err)
         })
      resolve()
    })
  }
}
export default actions
