<template>
  <div id="editor-js">
    <div :id="holderId"
         class="editor-js"></div>
  </div>
</template>

<script>
export const PLUGIN_PROPS = ['header', 'personality', 'list', 'code', 'inlineCode', 'embed', 'linkTool', 'marker', 'table', 'raw', 'delimiter', 'quote', 'image', 'warning', 'paragraph', 'checklist']

import EditorJS     from '@editorjs/editorjs'
import header       from '@editorjs/header'
import list         from '@editorjs/list'
import image        from '@editorjs/image'
import personality  from '@editorjs/personality'
import inlineCode   from '@editorjs/inline-code'
import table        from '@editorjs/table'
import embed        from '@editorjs/header'
import quote        from '@editorjs/quote'
import marker       from '@editorjs/marker'
import code         from '@editorjs/code'
import linkTool     from '@editorjs/link'
import delimiter    from '@editorjs/delimiter'
import raw          from '@editorjs/raw'
import warning      from '@editorjs/warning'
import paragraph    from '@editorjs/paragraph'
import checklist    from '@editorjs/checklist'
import underline    from '@editorjs/underline'
import attachesTool from '@editorjs/attaches'

//import DragDrop from 'editorjs-drag-drop'
//import Undo     from 'editorjs-undo'

export default {
  name: 'EditorJs',

  components: {
    //componentName: () => import(/* webpackChunkName: "componentName" */ './componentName')
  },

  props: {
    holderId:    {
      type:     String,
      default:  () => 'vue-editor-js',
      required: false
    },
    autofocus:   {
      type:     Boolean,
      default:  () => true,
      required: false
    },
    placeholder: {
      type:     String,
      default:  () => 'Начинайте писать здесь!',
      required: false
    },
    data:        {
      type:     Object,
      default:  () => {},
      required: false
    }
    //tools:       {
    //  type:     Object,
    //  default:  () => {},
    //  required: false
    //}
  },

  data () {
    return {
      editor: null,

      tools:  {

        header:     {
          class:  header,
          config: {
            placeholder:  'Напишите заголовок',
            levels:       [2, 3, 4, 5, 6],
            defaultLevel: 3
          }
        },

        img:        {
          class:         image,
          inlineToolbar: true
        },

        image:        {
          class:         image,
          config: {
            endpoints: {
              byFile: 'https://editor-upload.herokuapp.com/image',
              byUrl: 'https://editor-upload.herokuapp.com/image-by-url',
            }
          }
        },

        list:       {
          class:         list,
          inlineToolbar: true
        },

        code:       {
          class: code
        },

        paragraph:  {
          class: paragraph
        },

        embed:      {
          class:  embed,
          config: {
            services: {
              youtube: true,
              coub:    true,
              imgur:   true
            }
          }
        },

        table:      {
          class:         table,
          inlineToolbar: true,
          config:        {
            rows: 2,
            cols: 3
          }
        },
        checklist:  {
          class: checklist
        },

        marker:     {
          class:    marker,
          shortcut: 'CMD+SHIFT+M'
        },

        warning:    {
          class:         warning,
          inlineToolbar: true,
          shortcut:      'CMD+SHIFT+W',
          config:        {
            titlePlaceholder:   'Title',
            messagePlaceholder: 'Message'
          }
        },

        raw:        raw,
        quote:      {
          class:         quote,
          inlineToolbar: true,
          shortcut:      'CMD+SHIFT+O',
          config:        {
            quotePlaceholder:   'Enter a quote',
            captionPlaceholder: 'Quote\'s author'
          }
        },

        inlineCode: {
          class:    inlineCode,
          shortcut: 'CMD+SHIFT+M'
        },

        delimiter:  delimiter,

        //textSpolier: textSpolier,

        underline:  underline

        //attaches: {
        //  class: attachesTool,
        //  config: {
        //    endpoint: 'http://localhost:8008/uploadFile'
        //  }
        //}
      },

      value:  null
    }
  },

  mounted () {
    this.initEditor()
  },

  beforeDestroy () {
    if (this.editor) {
      this.destroy()
    }
  },

  watch: {
    //data () {
    //  this.initEditor()
    //},

  },

  methods: {

    initEditor () {
      if (this.editor) {
        this.editor.isReady
            .then(() => {
              this.editor.render(this.data)
            })
            .catch(e => console.log(e))
      }
      else {
        this.editor = new EditorJS({
          holder:      this.holderId,
          autofocus:   this.autofocus,
          placeholder: this.placeholder,
          logLevel:    'ERROR',

          onReady: () => {
            //new Undo({editor})
            //new DragDrop(editor)
            this.$emit('ready')
          },

          onChange: async () => {
            const response = await this.editor.save()
            this.$emit('update', response)
            console.log('change')
          },

          //onChange: async () => {
          //  const response = await this.editor.save()
          //  this.$emit('update', response)
          //},

          data:  this.data,
          tools: this.tools
        })
      }
    },

    async save () {
      const response = await this.editor.save()
      this.$emit('update', response)
    },

    destroy () {
      this.editor.destroy()
      this.editor = null
    }
  }
}
</script>
<style lang="sass">
@import "./sass/editor-js"
</style>
