const mutations = {

  // статус - запрос авторизации
  auth_request (state) {
    state.user.status = 'loading'
  },

  // статус - успешная авторизация
  auth_success (state, user) {
    state.user.status  = 'success'
    state.user.token   = user.token
    state.user.profile = user.profile
  },

  // статус - ошибка авторизации
  auth_error (state) {
    state.user.status = 'error'
  },

  logout (state) {
    state.user.status  = ''
    state.user.token   = ''
    state.user.profile = ''
  }

}
export default mutations

