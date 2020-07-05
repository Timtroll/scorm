const mutations = {

  setListRoot (state, data) {state.list = data},
  setListLevel (state, data) {
    state.list.push(data)
  }
}
export default mutations

