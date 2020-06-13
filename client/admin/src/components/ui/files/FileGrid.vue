<template>
  <div class="pos-list-files"
       v-if="data.length">

    <!-- pos-list-file-->
    <div class="pos-list-file"
         @click="openLightBox(file)"
         v-for="file in data">

      <div class="pos-list-files__image"
           :style="filePreview(file)">

        <!-- meta-->
        <div class="pos-list-files__meta">
          <div v-text="file.title"></div>
          <div v-text="prettyBytes(file.size)"></div>
          <div v-text="file.mime"></div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import {fileType, prettyBytes} from '../../../store/methods'

export default {
  name: 'FileGrid',

  props: {
    data: {
      type:    Array,
      default: () => {}
    }
  },

  data () {
    return {}
  },

  methods: {

    openLightBox (item) {
      if(!item.mime) return
      const type = fileType(item.mime)
      if (type === 'image') {
        console.log(item.url)
      }

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
