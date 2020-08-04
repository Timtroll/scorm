const mutations = {

  setListRoot (state, data) {

    data.list.forEach(i => {
      i.search = []

      if (i.keywords)
        i.search.push(i.keywords)
      if (i.description)
        i.search.push(i.description)
      if (i.label)
        i.search.push(i.label)

      i.search = i.search.join(' ')
    })
    state.listRoot = data
  },

  setListLevel (state, data) {
    state.list.push(data)
  }
}
export default mutations

