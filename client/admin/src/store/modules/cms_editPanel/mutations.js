const mutations = {

  /** RIGHT Panel */

  // статус
  editPanel_status_request (state) {state.editPanel.status = 'loading'},
  editPanel_status_success (state, data) {state.editPanel.status = 'success'},
  editPanel_status_error (state) {state.editPanel.status = 'error'},

  // right Panel Size
  editPanel_size (state, data) {
    state.editPanel.large = data
  },

  editPanel_show (state, data) {
    state.editPanel.open = data
  },

  editPanel_group (state, data) {
    state.editPanel.group = data
  },

  editPanel_data (state, data) {
    state.editPanel.item = data
  },



}
export default mutations

