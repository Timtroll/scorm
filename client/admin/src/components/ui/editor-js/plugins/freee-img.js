import filesClass from '@/api/upload/files'

const files = new filesClass

export default class FreeeImg {

  constructor ({data}) {

    this.file = {
      description: null,
      file:        null
    }
    this._status = ''
    this._data    = {}
    this._element = this._drawView()
    this.data = data
  }

  static get toolbox () {
    return {
      title: 'FeeeImage',
      icon:  `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" 
        viewBox="0 0 24 24" stroke-width="1.5" fill="none" 
        stroke-linecap="round" stroke-linejoin="round">
          <path stroke="none" d="M0 0h24v24H0z"/>
          <path d="M4 17v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2 -2v-2" />
          <polyline points="7 9 12 4 17 9" />
          <line x1="12" y1="4" x2="12" y2="16" />
        </svg>`
    }
  }

  render () {
    return this._element
  }

  save (blockContent) {
    return {
      url: blockContent.value
    }
  }

  async _search (id) {
    const response = await files.search(id)
    const data     = await response
    return data.data[0]
  }

  async _upload () {

    this._status = 'upload'
    let formData = new FormData()
    formData.append('description', this.file.description)
    formData.append('upload', this.file.file)

    const response = await files.upload(data)
    if (response.status === 'ok') {
      const id = response.id
      if (id) {
        const meta = await this._search(id)
        console.log(meta)
        this._status = 'success'
      }
    }
  }

  _drawView () {
    let outer = document.createElement('div')
                        .classList
                        .add('uk-width-medium', 'uk-padding')

    let fileWrap = document.createElement('div')
                           .setAttribute('uk-form-custom', '')

    let file = document.createElement('input')
                       .setAttribute('type', 'file')

    let selectFile = document.createElement('button')
                             .classList
                             .add('uk-button', 'uk-width-1-1', 'uk-button-default')
                             .setAttribute('tabindex', '-1')
                             .setAttribute('tabindex', 'button')

    fileWrap.append(file).append(selectFile)
    outer.append(fileWrap)

    return outer
  }
}
