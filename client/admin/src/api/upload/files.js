import serverHttp from '@/api/serverHttp'

export default class files {

  /**
   * Загрузить файл, добавить запись в таблицу
   * @returns {Promise<void>}
   * @param upload
   */
  async upload (upload) {
    if (!upload) return null
    return await this.serverHttp('/upload/', upload)
  }

  /**
   * Получить запись о файле по id или по имени файла ( приоритет id), хотя бы одно из полей обязательно
   * @returns {Promise<any>}
   * @param string
   */
  async search (string) {
    const formData = new FormData()
    if (string) {
      formData.append('search', string)
    }
    return await this.serverHttp('/upload/search/', formData)
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
    return await this.serverHttp('/upload/delete/', formData, true)
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
    return await this.serverHttp('/upload/update/', formData, true, true)
  }

  async serverHttp (url, params, notifyOk, notifyFail) {
    await serverHttp.query(url, params, notifyOk, notifyFail)
  }

}
