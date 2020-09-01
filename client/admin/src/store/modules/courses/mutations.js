const mutations = {

  setList (state, data) {

    console.log(data)

    if (data.data.list) {
      data.data.list.forEach(i => {
        i.search = []
        if (i.keywords)
          i.search.push(i.keywords)
        if (i.description)
          i.search.push(i.description)
        if (i.label)
          i.search.push(i.label)
        i.search = i.search.join(' ')
      })
    }

    console.log('setList', data)
    state.list[data.level] = data.data
  }

}
export default mutations

