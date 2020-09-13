import serverHttp from '@/api/serverHttp'

export default class files {

  async load (route, id) {
    const formData = new FormData()
    if (id) {
      formData.append('parent', id)
    }
    return await this.serverHttp(`${route}`, formData)
  }

  async edit (route, id) {
    const formData = new FormData()
    if (id) {
      formData.append('id', id)
    }
    return await this.serverHttp(`${route}`, formData)
  }

  async save (route, items) {
    const formData = new FormData()

    console.log('items', items)

    items.forEach(i => {
      console.log(i.name, i.value)
      formData.append(i.name, i.value || '')
    })

    return await this.serverHttp(`${route}`, formData)
  }

  async delete (route, id) {
    const formData = new FormData()
    if (id) {
      formData.append('id', id)
    }
    return await this.serverHttp(`${route}`, formData)
  }

  async add (route) {
    return await this.serverHttp(`${route}`)
  }

  async serverHttp (url, params, notifyOk, notifyFail) {
    await serverHttp.query(url, params, notifyOk, notifyFail)
  }

}
