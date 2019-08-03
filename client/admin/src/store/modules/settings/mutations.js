const mutations = {

  // статус - запрос авторизации
  auth_request (state) {
    state.user.status = 'loading'
  }

}
export default mutations

