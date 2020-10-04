import serverHttp from '@/api/serverHttp'

export default class files {

  /**
   * Загрузить файл, добавить запись в таблицу
   * @returns {Promise<void>}
   * @param upload
   */
  async upload (upload) {
    if (!upload) return null
    return await this.serverHttp('/upload/', upload, true, true, true)
  }

  /**
   * Получить запись о файле по id или по имени файла ( приоритет id), хотя бы одно из полей обязательно
   * @returns {Promise<any>}
   * @param string
   */
  async search (string) {
    return await this.serverHttp('/upload/search/', {'search': string}, false, true, false)
  }

  /**
   * Удалить файл и запись о нём
   * @param id
   * @returns {Promise<any>}
   */
  async delete (id) {
    if (!id) return
    return await this.serverHttp('/upload/delete/', {'id': id}, true, true, false)
  }

  /**
   * Обновить описание файла
   * @param id
   * @param description
   * @returns {Promise<any>}
   */
  async update (id, description) {
    if (!id && !description) return
    const formData = {
      id:          id,
      description: description
    }
    return await this.serverHttp('/upload/update/', formData, true, true, false)
  }

  async serverHttp (url, params, notifyOk, notifyFail, file) {
    await serverHttp.query(url, params, notifyOk, notifyFail, file)
  }

}
