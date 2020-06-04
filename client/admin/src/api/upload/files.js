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
   * @param upload
   * @param description
   * @returns {Promise<[]>}
   */
  async upload (upload, description) {
    console.log(upload, description)

    return await this.serverHttp('/', {
      upload:      upload,
      description: description
    })

    //Multiply Files

    //if (upload.isArray()) {
    //  const data = []
    //  for (const file of upload) {
    //    const response = await this.serverHttp('/', {
    //      upload:      file,
    //      description: description
    //    })
    //    response.push(data)
    //  }
    //  return data
    //}

    //Single Files

    //else {
    //  return await this.serverHttp('/', {
    //    upload:      upload,
    //    description: description
    //  })
    //}
  }

  /**
   * Получить запись о файле по id или по имени файла ( приоритет id), хотя бы одно из полей обязательно
   * @param id
   * @param filename
   * @returns {Promise<any>}
   */
  async search (id, filename) {
    if (id || filename) return
    return await this.serverHttp('/search/', {
      id:       id,
      filename: filename
    })
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
      'method':  'POST',
      'headers': {
        'Content-Type': 'multipart/form-data'
      },
      'body':    JSON.stringify(params)
    })

    const result = await response.json()
    console.log(result.message)

    if (result.status === 'ok') {
      return result
    }

    if (result.status === 'fail') {
      notify('ERROR: ' + result.message, 'danger')
      throw (result.message)
    }

  }

}
