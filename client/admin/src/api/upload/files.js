import serverHttp from '@/api/serverHttp'

export default class files {

  constructor () {
    this.token = localStorage.getItem('token')
  }

  /**
   * Загрузить файл, добавить запись в таблицу
   * @returns {Promise<void>}
   * @param upload
   */
  async upload (upload) {
    if (!upload) return null
    return await this.serverHttp('/', upload)
  }

  /**
   * Получить запись о файле по id или по имени файла ( приоритет id), хотя бы одно из полей обязательно
   * @returns {Promise<any>}
   * @param sting
   */
  async search (sting) {
    const formData = new FormData()
    if (sting) {
      formData.append('search', sting)
    }
    return await this.serverHttp('/search/', formData)
  }

  /**
   * Удалить файл и запись о нём
   * @param id
   * @returns {Promise<any>}
   */
  async delete (id) {
    if (!id) return
    const formData = new FormData()
    if (id) {
      formData.append('id', id)
    }
    return await this.serverHttp('/delete/', formData, true)
  }

  /**
   * Обновить описание файла
   * @param id
   * @param description
   * @returns {Promise<any>}
   */
  async update (id, description) {
    if (!id && !description) return
    const formData = new FormData()
    if (id) {
      formData.append('id', id)
      formData.append('description', description)
    }
    return await this.serverHttp('/update/', formData, true)
  }

  async serverHttp (url, params, notifyOk, notifyFail) {
    await serverHttp.query(url, params, notifyOk, notifyFail)
  }

}
