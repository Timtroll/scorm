<template>
  <div class="">
    <div>
      <label v-text="label || placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="label || placeholder"/>

      <div class="uk-form-controls">

        <tinymce-editor api-key="j2ynfnyyenyzjjso1khgj2fq4w75rqhmf3gcwbc7lpx6l1lf"
                        v-model="valueInput"
                        :init="editorInit"
                        :disabled="editorDisabled"/>
        <!--:init="editorInit"-->
        <!--api-key="j2ynfnyyenyzjjso1khgj2fq4w75rqhmf3gcwbc7lpx6l1lf"-->

      </div>

    </div>
  </div>
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
        valueInput: this.value,

        editorDisabled: false,
        editorInit:     {
          plugins: [
            'wordcount',
            'autolink',
            'autoresize',
            'codesample',
            'fullscreen',
            'image',
            'insertdatetime',
            'link',
            'linkchecker',
            'powerpaste',
            'searchreplace'
          ],

          external_plugins: {
            tiny_mce_wiris: 'https://freee.su/vendors/mathtype-tinymce4/plugin.min.js'
            //tiny_mce_wiris: 'https://www.wiris.net/demo/plugins/tiny_mce/plugin.js'
          },

          images_upload_url: 'https://drive.smartcheque.ru/up.php',
          automatic_uploads: true,

          //wirisimagebgcolor:      '#ffffff',
          //wirisimagesymbolcolor:  '#000000',
          //wiristransparency:      'true',
          //wirisimagefontsize:     '16',
          //wirisimagenumbercolor:  '#000000',
          //wirisimageidentcolor:   '#000000',
          //wirisformulaeditorlang: 'ru',

          //menubar:             'insert',
          //toolbar:             'link',
          //toolbar: ['fullscreen', 'link', 'searchreplace'],
          toolbar: ['fullscreen', 'link', 'searchreplace', 'tiny_mce_wiris_formulaEditor,tiny_mce_wiris_formulaEditorChemistry'],

          default_link_target:    '_blank',
          insertdatetime_formats: ['%H:%M:%S', '%Y-%m-%d', '%I:%M:%S %p', '%D'],
          autoresize_on_init:     true,

          branding: false,
          height:   400,
          encoding: 'xml'
        }

      }
    },

    mounted () {
      //console.log(ClassicEditor.builtinPlugins.map(plugin => plugin.pluginName))
    },

    watch: {

      valueInput () {
        this.$emit('value', this.valueInput)
      }
    },

    computed: {

      isChanged () {
        return JSON.stringify(this.valueInput) !== JSON.stringify(this.value)
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
        this.$emit('value', JSON.stringify(this.valueInput))
      }
    }
  }
</script>
