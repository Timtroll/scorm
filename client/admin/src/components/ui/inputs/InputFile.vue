<template>
  <li>
    <div>

      <label v-text="label"
             class="uk-form-label uk-text-truncate uk-margin-small-bottom"
             v-if="label"/>

      <div class="uk-form-controls">

        <!--pos-list-files-->
        <div class="pos-list-files"
             v-if="preview.length">

          <!-- pos-list-file-->
          <div class="pos-list-file"
               v-for="(file, index) in preview">

            <div class="pos-list-files__image"
                 :style="filePreview(file)">

              <!-- upload-->
              <transition name="fade"
                          appear>
                <div v-if="file.status === 'upload'"
                     class="pos-list-files__upload">
                  <div uk-spinner></div>
                </div>
              </transition>

              <!-- success-->
              <transition name="fade"
                          appear>
                <div v-if="file.status === 'success'"
                     class="pos-list-files__upload">
                  <span uk-icon="icon: check; ratio: 2"></span>
                </div>
              </transition>

              <div class="pos-list-files__meta">
                <div v-text="file.name"></div>
                <div v-text="prettyBytes(file.size)"></div>
              </div>
            </div>

            <button type="button"
                    @click.prevent="removeUploadFile(index)"
                    class="uk-button uk-button-danger pos-list-files__button uk-button-small">

              <img src="/img/icons/icon__trash.svg"
                   uk-svg
                   width="12"
                   height="12">
            </button>

            <!--pos-list-files__description-->
            <div class="pos-list-files__description">
              <input class="uk-input uk-form-small uk-width-1-1"
                     placeholder="Описание файла"
                     v-model="file.description">
            </div>

          </div>

        </div>

        <div class="uk-grid-small"
             uk-grid>

          <div class="uk-width-expand"
               uk-form-custom="target: true">
            <input class="uk-input"
                   ref="files"
                   multiple
                   type="file"
                   @change="handleFiles"
                   :placeholder="placeholder">
            <input class="uk-input uk-width-1-1"
                   type="text"
                   placeholder="Выбрать файл"
                   disabled>
          </div>

          <div class="uk-width-auto">
            <button class="uk-button uk-button-default"
                    :disabled="disabledUpload"
                    @click.prevent="upload">

              <img src="/img/icons/icon__save.svg"
                   uk-svg
                   width="20"
                   height="20"></button>
          </div>

        </div>

        <pre>{{uploadedPreview}}</pre>
      </div>
    </div>
  </li>
</template>

<script>
import filesClass from './../../../api/upload/files'
import {notify, prettyBytes} from '../../../store/methods'

const files = new filesClass

export default {
  name: 'InputFile',

  props: {

    value:       '',
    name:        '',
    label:       {
      default: '',
      type:    String
    },
    placeholder: {
      default: '',
      type:    String
    },
    readonly:    {default: 0, type: Number},
    required:    {default: 0, type: Number}

  },

  data () {
    return {
      valueInput:      this.value || [],
      valid:           true,
      files:           [],
      image:           [],
      preview:         [],
      uploadedPreview: [],
      maxUploadCount:  10
    }
  },

  computed: {

    disabledUpload () {
      return !this.preview.length
    },

    isChanged () {
      return this.valueInput !== this.value
    }
  },

  methods: {

    async upload () {

      for (const file of this.preview) {
        file.status  = 'upload'
        let formData = new FormData()
        formData.append('description', file.description)
        formData.append('upload', file.file)
        // upload file
        await this.fileUpload(formData)
        file.status = 'success'
        // remove preview file
        this.preview.splice(this.preview.indexOf(file), 1)
      }
    },

    async fileUpload (data, index) {
      const response = await files.upload(data)
      console.log('response.id', response.id)
      const id = await response.id
      this.valueInput.push(id)
      await this.searchFile(id)
    },

    async searchFile (id) {
      const response = await files.search(id)
      const data     = await response
      this.uploadedPreview.push(data.data)

    },

    removeUploadFile (index) {
      this.preview.splice(index, 1)
    },

    handleFiles (event) {
      const files = event.target.files || event.dataTransfer.files
      if (!files.length) return
      this.files = files
      for (let i = 0; i < files.length; i++) {
        const isImage = this.fileIsImage(files[i].type)
        //console.log(files[i])
        const file = {
          file:        files[i],
          image:       '',
          isImage:     isImage,
          status:      'none', // none | upload | success | error
          type:        files[i].type,
          name:        files[i].name,
          size:        files[i].size,
          description: ''
        }

        if (i <= this.maxUploadCount) {
          this.preview.push(file)
          if (!isImage) return
          this.createImage(files[i], i)
        } else {
          notify('Одновременно разрешено загружать не более ' + this.maxUploadCount + '-ти файлов')
        }
      }
    },

    createImage (file, index) {
      let reader    = new FileReader()
      reader.onload = (e) => {
        this.preview[index].image = e.target.result
      }
      reader.readAsDataURL(file)
    },

    update () {
      this.$emit('change', this.isChanged)
      //this.$emit('value', this.valueInput)
    },

    fileIsImage (type) {
      switch (type) {
        case 'image/jpeg':
          return true
        case 'image/png':
          return true
        case 'image/gif':
          return true
        case 'image/svg+xml':
          return true
        case 'image/webp':
          return true
        default:
          return false
      }
    },

    filePreview (item) {
      const style = {
        backgroundImage: 'url(/files-icon/more.svg)',
        backgroundSize:  '60px 60px' //'cover'
      }
      const type  = item.type
      const image = item.image
      switch (type) {
        case 'image/jpeg':
          style.backgroundImage = 'url(' + image + ')'
          style.backgroundSize  = 'cover'
          break
        case 'image/png':
          style.backgroundImage = 'url(' + image + ')'
          style.backgroundSize  = 'cover'
          break
        case 'image/svg+xml':
          style.backgroundImage = 'url(' + image + ')'
          style.backgroundSize  = 'cover'
          break
        case 'image/webp':
          style.backgroundImage = 'url(' + image + ')'
          style.backgroundSize  = 'cover'
          break
        case 'image/gif':
          style.backgroundImage = 'url(' + image + ')'
          style.backgroundSize  = 'cover'
          break
        case 'application/zip':
          style.backgroundImage = 'url(/files-icon/zip.svg)'
          style.backgroundSize  = '60px 60px'
          break
        case 'application/pdf':
          style.backgroundImage = 'url(/files-icon/pdf.svg)'
          style.backgroundSize  = '60px 60px'
          break
        case 'audio/mp4':
          style.backgroundImage = 'url(/files-icon/mp3.svg)'
          style.backgroundSize  = '60px 60px'
          break
        case 'audio/mpeg':
          style.backgroundImage = 'url(/files-icon/mp3.svg)'
          style.backgroundSize  = '60px 60px'
          break
        case 'audio/aac':
          style.backgroundImage = 'url(/files-icon/mp3.svg)'
          style.backgroundSize  = '60px 60px'
          break
        case 'audio/webm':
          style.backgroundImage = 'url(/files-icon/mp3.svg)'
          style.backgroundSize  = '60px 60px'
          break
        case 'video/mpeg':
          style.backgroundImage = 'url(/files-icon/mov.svg)'
          style.backgroundSize  = '60px 60px'
          break
        case 'video/mp4':
          style.backgroundImage = 'url(/files-icon/mov.svg)'
          style.backgroundSize  = '60px 60px'
          break
        case 'video/quicktime':
          style.backgroundImage = 'url(/files-icon/mov.svg)'
          style.backgroundSize  = '60px 60px'
          break
        case 'video/webm':
          style.backgroundImage = 'url(/files-icon/mov.svg)'
          style.backgroundSize  = '60px 60px'
          break
        case 'application/vnd.ms-excel':
          style.backgroundImage = 'url(/files-icon/xls.svg)'
          style.backgroundSize  = '60px 60px'
          break
        case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
          style.backgroundImage = 'url(/files-icon/xls.svg)'
          style.backgroundSize  = '60px 60px'
          break
        case 'application/vnd.ms-powerpoint':
          style.backgroundImage = 'url(/files-icon/ppt.svg)'
          style.backgroundSize  = '60px 60px'
          break
        case 'application/vnd.openxmlformats-officedocument.presentationml.presentation':
          style.backgroundImage = 'url(/files-icon/ppt.svg)'
          style.backgroundSize  = '60px 60px'
          break
        case 'application/msword':
          style.backgroundImage = 'url(/files-icon/doc.svg)'
          style.backgroundSize  = '60px 60px'
          break
        case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
          style.backgroundImage = 'url(/files-icon/doc.svg)'
          style.backgroundSize  = '60px 60px'
          break
        case 'text/plain':
          style.backgroundImage = 'url(/files-icon/documents.svg)'
          style.backgroundSize  = '60px 60px'
          break

      }
      return style
    },

    prettyBytes (num) {
      return prettyBytes(num)
    }
  }
}
</script>
