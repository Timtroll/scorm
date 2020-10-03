const mutations = {

  set_time (state, data) {state.time = data},

  page_title (state, data) {state.pageTitle = data},
  page_sub_title (state, data) {state.pageSubTitle = data},

  // акшин для левой кнопки в navbar
  card_left_show (state, data) {
    state.card.leftShow = data
  },

  card_right_show (state, data) {
    state.card.rightShow = data
  },

  card_left_nav_click (state) {
    state.card.leftNavClick = !state.card.leftNavClick
  },

  navBarLeftActionShow (state, data) {
    state.navBarLeftAction.visibility = data
  },

  setConfig (state, data) {
    state.config = data
  }

}
export default mutations

