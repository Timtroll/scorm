const mutations = {

  page_title (state, data) {state.pageTitle = data},

  // акшин для левой кнопки в navbar
  card_left_show (state, data) {
    state.card.leftShow = data
  },

  card_right_show (state, data) {
    state.card.rightShow = data
  },

  card_left_nav_click (state) {
    state.card.leftNavClick = !state.card.leftNavClick
  }

}
export default mutations

