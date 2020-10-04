const getters = {

  isLoggedIn: state => !!state.user.token,
  authStatus: state => state.user.status,
  profile:    state => state.user.profile

}

export default getters
