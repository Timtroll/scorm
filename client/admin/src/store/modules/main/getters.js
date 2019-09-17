const getters = {

  inputComponents: state => state.inputComponents,

  pageTitle: state => state.pageTitle,

  navBarLeftAction: state => state.navBarLeftAction,

  cardLeftState:       state => state.card.leftShow,
  cardRightPanelLarge: state => state.card.rightPanelLarge,
  cardRightState:      state => state.card.rightShow,
  cardLeftClickAction: state => state.card.leftShow

}

export default getters
