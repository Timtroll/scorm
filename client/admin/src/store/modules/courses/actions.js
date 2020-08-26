import coursesClass from '@/api/courses'
import {notify}     from '@/store/methods'

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
