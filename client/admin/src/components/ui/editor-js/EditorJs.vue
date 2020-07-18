<template>
  <div id="editor-js">
    <div :id="holderId"
         class="editor-js"></div>
  </div>
</template>

<script>
export const PLUGIN_PROPS = ['header', 'personality', 'list', 'code', 'inlineCode', 'embed', 'linkTool', 'marker', 'table', 'raw', 'delimiter', 'quote', 'image', 'warning', 'paragraph', 'checklist']

const PLUGINS = {
  header:      require('@editorjs/header'),
  list:        require('@editorjs/list'),
  image:       require('@editorjs/image'),
  personality: require('@editorjs/personality'),
  inlineCode:  require('@editorjs/inline-code'),
  embed:       require('@editorjs/embed'),
  quote:       require('@editorjs/quote'),
  marker:      require('@editorjs/marker'),
  code:        require('@editorjs/code'),
  linkTool:    require('@editorjs/link'),
  delimiter:   require('@editorjs/delimiter'),
  raw:         require('@editorjs/raw'),
  table:       require('@editorjs/table'),
  warning:     require('@editorjs/warning'),
  paragraph:   require('@editorjs/paragraph'),
  checklist:   require('@editorjs/checklist'),
  //textSpoiler:  require('editorjs-inline-spoiler-tool'),
  //attachesTool: require('@editorjs/attaches'),
  underline:   require('@editorjs/underline')
}

import EditorJS from '@editorjs/editorjs'
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
          class:  PLUGINS.header,
          config: {
            placeholder:  'Напишите заголовок',
            levels:       [2, 3, 4, 5, 6],
            defaultLevel: 3
          }
        },
        list:       {
          class:         PLUGINS.list,
          inlineToolbar: true
        },
        code:       {
          class: PLUGINS.code
        },
        paragraph:  {
          class: PLUGINS.paragraph
        },
        embed:      {
          class:  PLUGINS.embed,
          config: {
            services: {
              youtube: true,
              coub:    true,
              imgur:   true
            }
          }
        },
        table:      {
          class:         PLUGINS.table,
          inlineToolbar: true,
          config:        {
            rows: 2,
            cols: 3
          }
        },
        checklist:  {
          class: PLUGINS.checklist
        },
        Marker:     {
          class:    PLUGINS.marker,
          shortcut: 'CMD+SHIFT+M'
        },
        warning:    {
          class:         PLUGINS.warning,
          inlineToolbar: true,
          shortcut:      'CMD+SHIFT+W',
          config:        {
            titlePlaceholder:   'Title',
            messagePlaceholder: 'Message'
          }
        },
        raw:        PLUGINS.raw,
        quote:      {
          class:         PLUGINS.quote,
          inlineToolbar: true,
          shortcut:      'CMD+SHIFT+O',
          config:        {
            quotePlaceholder:   'Enter a quote',
            captionPlaceholder: 'Quote\'s author'
          }
        },
        inlineCode: {
          class:    PLUGINS.inlineCode,
          shortcut: 'CMD+SHIFT+M'
        },
        delimiter:  PLUGINS.delimiter,
        image:      PLUGINS.image,
        //textSpolier: PLUGINS.textSpolier,
        underline:  PLUGINS.underline
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
      //this.$emit('update', response)
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
