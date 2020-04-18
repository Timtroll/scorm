const getters = {

  isLoggedIn: state => !!state.user.token,
  authStatus: state => state.user.status

}

export default getters
