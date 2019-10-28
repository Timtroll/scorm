<template>
  <li>
    <label v-text="label || placeholder"
           class="uk-form-label uk-text-bold uk-text-truncate"
           v-if="label || placeholder"/>

    <div class="uk-form-controls uk-margin-small-top">
      <tinymce-editor api-key="j2ynfnyyenyzjjso1khgj2fq4w75rqhmf3gcwbc7lpx6l1lf"
                      v-model="valueInput"
                      :init="editorInit"
                      @onChange="update"
                      :disabled="editorDisabled"/>
    </div>
  </li>
</template>

<script>

  import Editor from '@tinymce/tinymce-vue'

  export default {
    name: 'InputTinyMCE',

    props: {
      value:       {},
      label:       {
        default: '',
        type:    String
      },
      placeholder: {
        default: '',
        type:    String
      },
      editable:    {default: 1},
      required:    {}
    },

    components: {
      'tinymce-editor': Editor
    },

    data () {
      return {
        valueInput:     this.value,
        editorDisabled: false,
        editorInit:     {

          plugins:
            'print ' +
            'preview ' +
            'paste ' +
            'importcss ' +
            'searchreplace ' +
            'autolink ' +
            'directionality ' +
            'visualblocks ' +
            'visualchars ' +
            'fullscreen ' +
            'image ' +
            'link ' +
            'media ' +
            'template ' +
            'code ' +
            'codesample ' +
            'table ' +
            'charmap ' +
            'hr ' +
            'pagebreak ' +
            'nonbreaking ' +
            'anchor ' +
            'toc ' +
            'insertdatetime ' +
            'advlist ' +
            'lists ' +
            'wordcount  ' +
            'imagetools ' +
            'textpattern ' +
            'noneditable ' +
            'help ' +
            'charmap ' +
            'quickbars ' +
            'emoticons',

          external_plugins: {
            tiny_mce_wiris: 'https://freee.su/vendors/mathtype-tinymce4/plugin.min.js'
          },

          images_upload_url: 'https://drive.smartcheque.ru/up.php',
          automatic_uploads: true,

          menubar: 'edit ' +
                     'view ' +
                     'insert ' +
                     'table',
          toolbar: 'fullscreen  preview code | ' +
                     'undo redo | ' +
                     'tiny_mce_wiris_formulaEditor tiny_mce_wiris_formulaEditorChemistry | ' +
                     'bold italic underline strikethrough | ' +
                     'formatselect | ' +
                     'outdent indent | ' +
                     'numlist bullist | ' +
                     'removeformat | ' +
                     'pagebreak | ' +
                     'charmap emoticons | ' +
                     'insertfile image media template link anchor codesample | ',

          quickbars_selection_toolbar: 'bold italic | quicklink h2 h3 blockquote quickimage',

          toolbar_drawer:         'sliding',
          contextmenu:            'link image imagetools table configurepermanentpen',
          default_link_target:    '_blank',
          insertdatetime_formats: ['%H:%M:%S', '%Y-%m-%d', '%I:%M:%S %p', '%D'],
          autoresize_on_init:     true,

          branding: false,
          height:   400,
          //encoding: 'xml',

          templates: [
            {
              title:       'Таблица',
              description: 'Создать новую таблицу',
              content:
                           '<div class="mceTmpl"><table class="uk-table uk-table-divider uk-table-small uk-table-striped"><tr><th scope="col"> </th><th scope="col"> </th></tr><tr><td> </td><td> </td></tr></table></div>'
            },
            {title: 'Starting my story', description: 'A cure for writers block', content: 'Once upon a time...'},
            {
              title:       'New list with dates',
              description: 'New List with dates',
              content:     '<div class="mceTmpl"><span class="cdate">cdate</span><br /><span class="mdate">mdate</span><h2>My List</h2><ul><li></li><li></li></ul></div>'
            }
          ]
        }
      }
    },

    mounted () {
      //console.log(ClassicEditor.builtinPlugins.map(plugin => plugin.pluginName))
    },

    watch: {

      valueInput () {
        if (this.mask) {
          this.valueInput = this.valueInput.replace(this.mask, '')
        }
      }
    },

    computed: {

      isChanged () {
        return this.valueInput !== this.value
      },

      validate () {

        let validClass = null
        if (this.required) {
          if (!this.valueInput && this.valueInput.length < 1) {
            validClass = 'uk-form-danger'
            this.valid = false
            this.$emit('valid', this.valid)
          } else {
            validClass = 'uk-form-success'
            this.valid = true
            this.$emit('valid', this.valid)
          }
        }
        return validClass
      }
    },

    methods: {

      update () {
        this.$emit('change', this.isChanged)
        this.$emit('value', this.valueInput)
      }
    }
  }
</script>
<style>
  .pos-card-body-right .tox-fullscreen {
    position: absolute;
  }
  .pos-card-body-right .tox-fullscreen .tox.tox-tinymce.tox-fullscreen {
    z-index: 10;
  }
  .tox-notifications-container {display: none !important;}
</style>
