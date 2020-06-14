<template>
  <div class="pos-list-files"
       v-if="data && data.length">

    <!-- pos-list-file-->
    <div class="pos-list-file"
         v-for="(file, index) in dataNew">

      <div class="pos-list-files__image"
           @click="openLightBox(file)"
           :style="filePreview(file)">

        <!-- upload-->
        <!--        <transition name="fade"-->
        <!--                    appear>-->
        <!--          <div v-if="file.status === 'upload'"-->
        <!--               class="pos-list-files__upload">-->
        <!--            <div uk-spinner></div>-->
        <!--          </div>-->
        <!--        </transition>-->

        <!-- success-->
        <!--        <transition name="fade"-->
        <!--                    appear>-->
        <!--          <div v-if="file.status === 'success'"-->
        <!--               class="pos-list-files__upload success">-->
        <!--            <img src="img/icons/icon__check.svg"-->
        <!--                 width="24"-->
        <!--                 height="24"-->
        <!--                 uk-svg>-->
        <!--          </div>-->
        <!--        </transition>-->

        <!-- error-->
        <!--        <transition name="fade"-->
        <!--                    appear>-->
        <!--          <div v-if="file.status === 'error'"-->
        <!--               class="pos-list-files__upload error">-->
        <!--            <img src="img/icons/icon__close.svg"-->
        <!--                 width="24"-->
        <!--                 height="24"-->
        <!--                 uk-svg>-->
        <!--          </div>-->
        <!--        </transition>-->

        <!-- meta-->
        <div class="pos-list-files__meta">
          <div v-text="file.title"></div>
          <div v-text="prettyBytes(file.size)"></div>
          <div v-text="file.mime"></div>
        </div>

      </div>

      <!--remove-->
      <button type="button"
              v-if="allowActions"
              @click="deleteFile(file.id, index)"
              class="uk-button uk-button-danger pos-list-files__button uk-button-small">
        <img src="/img/icons/icon__trash.svg"
             uk-svg
             width="12"
             height="12">
      </button>

      <!--description-->
      <div class="pos-list-files__description"
           v-if="allowActions">
        <input class="uk-input uk-form-small uk-width-1-1"
               placeholder="Описание файла"
               @change="updateFile(file.id, file.description)"
               v-model="dataNew[index].description">
      </div>

    </div>

  </div>
</template>

<script>
import {fileType, prettyBytes} from '../../../store/methods'
import filesClass from '../../../api/upload/files'

const files = new filesClass

export default {
  name: 'FileGrid',

  props: {
    data: {
      type:    Array,
      default: () => {}
    },

    allowActions: {
      type:    Boolean,
      default: false
    }
  },

  watch: {
    data () {
      this.dataNew = [...this.data]
    }
  },

  data () {
    return {
      dataNew: []
    }
  },

  methods: {

    openLightBox (item) {
      if (!item.mime) return
      const type = fileType(item.mime)
      if (type === 'image') {
        console.log(item.url)
      }
    },

    async deleteFile (id, index) {

      const d = confirm(this.$t('media.removeConfirm'))

      if (d) {
        const response = await files.delete(id)
        if (response.status === 'ok') {
          this.dataNew.splice(index, 1)
        }
      }

    },

    async updateFile (id, description) {
      await files.update(id, description)
    },

    filePreview (item) {
      const style = {
        backgroundImage: 'url(/files-icon/more.svg)',
        backgroundSize:  '60px 60px' //'cover'
      }
      const type  = item.mime
      const image = item.url
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
