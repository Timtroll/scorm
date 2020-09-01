import coursesClass                   from '@/api/courses'
import {clone, groupedFields, notify} from '@/store/methods'
import store                          from '@/store/store'

const courses = new coursesClass

const actions = {

  async getRoot ({commit}, data) {
    try {

      const response = await courses.load(data.route)
      if (response.status === 'ok') {
        commit('setList', response.data)
      }
    }
    catch (e) {_showError(e)}
  },

  async getLevel ({commit}, data) {
    try {
      console.log(data)
      const response = await courses.load(data.route, data.parent)
      if (response.status === 'ok') {
        commit('setList', {
          level: data.level,
          data:  response.data
        })
      }
    }
    catch (e) {_showError(e)}
  },

  async edit ({commit}, data) {
    try {
      store.commit('editPanel_status_request')
      const response = await courses.edit(data.route, data.id)
      if (response.status === 'ok') {
        const resp   = await response.data
        const proto  = clone(store.getters.editPanel_proto)
        const groups = groupedFields(resp, proto)
        _openPanel(groups)
      }
    }
    catch (e) {_showError(e)}
  },

  async add ({commit}, data) {
    try {
      const response = await courses.add(data.route)
      if (response.status === 'ok') {

        return response.id
      }
    }
    catch (e) {_showError(e)}
  },

  async save ({commit}, data) {
    try {
      store.commit('editPanel_status_request')
      const response = await courses.save(data.route, data.items)
      if (response.status === 'ok') {
        _closePanel(response.status)
      }
    }
    catch (e) {_showError(e)}
  },

  async delete ({commit}, data) {
    try {
      const confirm = window.confirm('Удалить?')
      if (!confirm) return

      const response = await courses.delete(data.route, data.id)
      if (response.status === 'ok') {
        console.log(response.data)
      }
    }
    catch (e) {_showError(e)}
  }

}

// helpers
function _showError (e) {
  notify('ERROR: ' + e, 'danger')
  throw 'ERROR: ' + e
}

function _openPanel (groups) {
  store.commit('editPanel_data', groups) // запись данных во VUEX
  store.commit('editPanel_status_success') // статус - успех
  store.commit('card_right_show', true) // открытие правой панели
}

function _closePanel (status) {
  store.commit('card_right_show', false)
  store.commit('editPanel_data', []) // очистка данных VUEX
  store.commit('editPanel_status_success') // статус - успех
  store.commit('courses/setSaveRoute', null)
  notify(status, 'success') // уведомление об ошибке
}

export default actions
