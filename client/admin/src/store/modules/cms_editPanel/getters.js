const getters = {

  editPanel_large:  state => state.editPanel.large,
  editPanel_status: state => state.editPanel.status,
  editPanel_item:   state => state.editPanel.item,
  editPanel_add:    state => state.editPanel.add,
  editPanel_folder: state => state.editPanel.folder,

  editPanel_proto: state => state.editPanel.proto,

  inputComponents: state => state.inputComponents,

  editPanel_api: state => state.editPanel.api

}

export default getters

