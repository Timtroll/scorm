import coursesClass                   from '@/api/courses'
import {clone, groupedFields, notify} from '@/store/methods'
import store                                    from '@/store/store'

const courses = new coursesClass

const actions = {

  async getRoot ({commit}, data) {
    try {

      const response = await courses.load(data.route)
      if (response.status === 'ok') {
        commit('setListRoot', response.data)
      }
    }
    catch (e) {
      notify('ERROR: ' + e, 'danger')
      throw 'ERROR: ' + e
    }
  },

  async edit ({commit}, data) {
    try {
      store.commit('editPanel_status_request')
      const response = await courses.edit(data.route, data.id)
      if (response.status === 'ok') {
        const resp  = await response.data
        const proto = clone(store.getters.editPanel_proto)
        console.log('--- response', response.data)
        //const groups =_groupedFields({})
        const groups = groupedFields(resp, proto)

        store.commit('editPanel_data', groups) // запись данных во VUEX
        store.commit('editPanel_status_success') // статус - успех
        store.commit('card_right_show', true) // открытие правой панели
      }
    }
    catch (e) {
      notify('ERROR: ' + e, 'danger')
      throw 'ERROR: ' + e
    }
  },

  async add ({commit}, data) {
    console.log('--- data', data)
    try {
      const response = await courses.add(data.route)
      if (response.status === 'ok') {
        return response.id
      }
    }
    catch (e) {
      notify('ERROR: ' + e, 'danger')
      throw 'ERROR: ' + e
    }
  },

  async remove ({commit}, data) {
    try {
      const response = await courses.add(data.route)
      if (response.status === 'ok') {
        console.log(response.data)
        //commit('setListRoot', response.data)
      }
    }
    catch (e) {
      notify('ERROR: ' + e, 'danger')
      throw 'ERROR: ' + e
    }
  },

  async getLevel ({commit, state}, data) {
    try {
      console.log(data)
      const response = await courses.load(data.route, data.id)
      if (response.status === 'ok') {

      }
    }
    catch (e) {
      notify('ERROR: ' + e, 'danger')
      throw 'ERROR: ' + e
    }
  }

}
export default actions
