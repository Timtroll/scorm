import router from './../../../router'
import {notify, flatTree} from '../../methods'
import Api from './../../../api/Tree'

const actions = {

  // Дерево категорий
  async getTree ({commit, state}) {

    try {
      commit('tree_status_request')

      const response = await Api.get_tree()
      //const routeId  = router.currentRoute.params.id

      if (response.status === 200) {
        const resp = await response.data

        if (typeof resp['list'] !== 'undefined') {
          const tree = resp.list

          if (tree.length > 0) {
            commit('set_tree', tree)
            commit('tree_status_success')

            //Плоское дерево
            const flattenTree = flatTree([...tree])
            commit('set_tree_flat', flattenTree)
          }
        }

      }

    } catch (e) {
      notify('ERROR: ' + e, 'danger')
      throw 'ERROR: ' + e
    }

  }

}
export default actions
