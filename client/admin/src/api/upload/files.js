import Vue from 'vue'
import {notify} from '../../store/methods'

let apiProxy = ''

if (!Vue.config.productionTip) {
  apiProxy = 'https://cors-c.herokuapp.com/https://freee.su' // для Localhost  https://cors-c.herokuapp.com
}
const apiUrl = apiProxy + '/upload'

export default class files {

  constructor () {
    this.url   = apiUrl
    this.token = localStorage.getItem('token')
  }

  /**
   * Загрузить файл, добавить запись в таблицу
   * @returns {Promise<[]>}
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
    if (id) return
    return await this.serverHttp('/delete/', {
      id: id
    })
  }

  /**
   * Обновить описание файла
   * @param id
   * @param description
   * @returns {Promise<any>}
   */
  async update (id, description) {
    if (id && description) return
    return await this.serverHttp('/update/', {
      id:          id,
      description: description
    })
  }

  async serverHttp (url, params) {
    const response = await fetch(this.url + url, {
      method:   'POST',
      body:     params,
      redirect: 'follow'
    })

    const result = await response.json()

    if (result.status === 'ok') {
      return result
    }

    if (result.status === 'fail') {

      notify('ERROR: ' + result.message, 'danger')
      return result
      //throw (result.message)
    }

  }

}
