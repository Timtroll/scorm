import router from './../../../router'
import {flatTree, notify} from './../../methods'
import Api from './../../../api/Tree'

const actions = {

  // Дерево категорий
  async getTree ({commit, state}) {

    try {
      commit('tree_status_request')

      let response = await Api.get_tree()

      if (response.status === 200) {
        const resp = await response.data

        if (typeof resp['list'] !== 'undefined') {
          const tree = resp.list

          console.log(tree)

          commit('set_tree', tree)
          commit('tree_status_success')

          //const routeId = router.currentRoute.params.id

          if (tree.length > 0) {
            //Плоское дерево
            //const _flatTree = flatTree([...tree])

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
