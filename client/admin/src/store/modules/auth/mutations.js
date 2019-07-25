const mutations = {

  // статус - запрос авторизации
  auth_request (state) {
    state.user.status = 'loading'
  },

  // статус - успешная авторизация
  auth_success (state, token, user) {
    state.user.status = 'success'
    state.user.token  = token
    state.user.user   = user
  },

  // статус - ошибка авторизации
  auth_error (state) {
    state.user.status = 'error'
  },

  logout (state) {
    state.user.status = ''
    state.user.token  = ''
  }

}
export default mutations

