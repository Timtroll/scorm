<template>
  <div class="">
    <div>
      <label v-text="label || placeholder"
             class="uk-form-label uk-text-bold uk-text-truncate"
             v-if="label || placeholder"/>

      <div class="uk-form-controls uk-margin-small-top">

        <vue-ckeditor type="classic"
                      v-model="valueInput"
                      :disabled="editorDisabled"
                      :config="editorConfig"
                      @input="update"
                      :editors="editors"/>

      </div>
      <!--<div class="uk-margin-top"-->
      <!--     v-html="valueInput"></div>-->
    </div>
  </div>
</template>

<script>

  import ClassicEditor from '@ckeditor/ckeditor5-build-classic'
  import VueCkeditor from 'vue-ckeditor5'

  // custom
  //import CKEditor from '@ckeditor/ckeditor5-vue';
  //import ClassicEditor from '@ckeditor/ckeditor5-editor-classic/src/classiceditor'
  //import EssentialsPlugin from '@ckeditor/ckeditor5-essentials/src/essentials'
  //import BoldPlugin from '@ckeditor/ckeditor5-basic-styles/src/bold'
  //import ItalicPlugin from '@ckeditor/ckeditor5-basic-styles/src/italic'
  //import LinkPlugin from '@ckeditor/ckeditor5-link/src/link'
  //import ParagraphPlugin from '@ckeditor/ckeditor5-paragraph/src/paragraph'

  //import '@ckeditor/ckeditor5-build-classic/build/translations/ru'

  //import VueCkeditor from 'vue-ckeditor5'

  export default {
    name: 'InputCKEditor',

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
      'vue-ckeditor': VueCkeditor.component
    },

    //components: {
    //  // Use the <ckeditor> component in this view.
    //  ckeditor: CKEditor.component
    //},

    data () {
      return {
        valueInput: this.value,

        editors: {
          classic: ClassicEditor
        },

        editorDisabled: true,

        //editorConfig: {
        //  plugins: [
        //    EssentialsPlugin,
        //    BoldPlugin,
        //    ItalicPlugin,
        //    //LinkPlugin,
        //    ParagraphPlugin
        //  ],
        //
        //  toolbar: {
        //    items: [
        //      'bold',
        //      'italic',
        //      'link',
        //      'undo',
        //      'redo'
        //    ]
        //  }
        //}

        editorConfig: {
          readonly:    false,
          placeholder: 'Начинайте вводить текст здесь...',
          //plugins: [
          //EssentialsPlugin,
          //BoldPlugin,
          //ItalicPlugin,
          //LinkPlugin,
          //ParagraphPlugin
          //],

          // Run the editor with the German UI.
          language: 'ru',
          //toolbar:  [
          //  'heading', '|',
          //  'undo', 'redo', '|',
          //  'bold', 'italic', 'link', 'bulletedList', 'numberedList', 'blockQuote', '|',
          //  'imageUpload'
          //],
          //
          //image:   {
          //  toolbar: [
          //    'imageStyle:full',
          //    'imageStyle:side',
          //    '|',
          //    'imageTextAlternative'
          //  ]
          //},

          simpleUpload: {
            // The URL that the images are uploaded to.
            uploadUrl: 'https://drive.smartcheque.ru/up.php',

            // Headers sent along with the XMLHttpRequest to the upload server.
            headers: {
              //'X-CSRF-TOKEN': 'CSFR-Token',
              //Authorization: 'Bearer <JSON Web Token>'
            }
          },

          heading: {
            options: [
              {model: 'paragraph', title: 'Paragraph', class: 'ck-heading_paragraph'},
              {model: 'heading2', view: 'h2', title: 'Heading 2', class: 'ck-heading_heading2'},
              {model: 'heading3', view: 'h3', title: 'Heading 3', class: 'ck-heading_heading3'},
              {model: 'heading4', view: 'h4', title: 'Heading 4', class: 'ck-heading_heading4'},
              {model: 'heading5', view: 'h5', title: 'Heading 5', class: 'ck-heading_heading5'},
              {model: 'heading6', view: 'h6', title: 'Heading 6', class: 'ck-heading_heading6'}
            ]
          }

        }
      }
    },

    mounted () {
      console.log(ClassicEditor.builtinPlugins.map(plugin => plugin.pluginName))
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
