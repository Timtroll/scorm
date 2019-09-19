


import actions from './actions'
import mutations from './mutations'
import getters from './getters'

const state = {

  tree: {
    status:   'loading',
    open:     false,
    activeId: null,
    items:    []
  },

  table: {
    status:     'loading',
    current:    null,
    tableFlat:  null,
    tableNames: null,
    items:      []
  },

  editPanel: {
    status: 'loading',
    show:   false,
    add:    true,
    large:  false,
    item:   {}
  },

  //editPanel: {
  //  state: {
  //    open:   false,
  //    status: 'loading'
  //  }
  //},

  //cms: {
  //  data:       null,
  //  status:     '',
  //  current:    null,
  //  table:      null,
  //  tableFlat:  null,
  //  tableNames: null,
  //  row:        {
  //    open:   false,
  //    status: 'loading',
  //    data:   null
  //  },
  //  addGroup:   {
  //    show: false,
  //    add:  true,
  //    data: {}
  //  },
  //  updateRow:  null
  //},

  main: {
    pageTitle:        '',
    navBarLeftAction: {
      visibility: true,
      icon:       'icon__nav.svg'
    },
    leftShow:         true,
    leftNavClick:     true,
    rightShow:        true,
    rightPanelLarge:  false
  },

  //pageLoader: true,



}

export default {
  namespaced: false,
  state:      state,
  actions:    actions,
  mutations:  mutations,
  getters:    getters
}
