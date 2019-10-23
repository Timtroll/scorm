<template>
  <div class="">
    <div>
      <label v-text="label || placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="label || placeholder"/>

      <div class="uk-form-controls">
        <!--<textarea class="uk-textarea pos-textarea"-->
        <!--          rows="3"-->
        <!--          :disabled="!editable"-->
        <!--          :class="validate"-->
        <!--          v-model="valueInput"-->
        <!--          @change="update"-->
        <!--          :placeholder="placeholder"></textarea>-->

        <vue-ckeditor type="classic"
                      v-model="valueInput"
                      :config="editorConfig"
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

  //import EssentialsPlugin from '@ckeditor/ckeditor5-essentials/src/essentials';
  //import BoldPlugin from '@ckeditor/ckeditor5-basic-styles/src/bold';
  //import ItalicPlugin from '@ckeditor/ckeditor5-basic-styles/src/italic';
  //import LinkPlugin from '@ckeditor/ckeditor5-link/src/link';
  //import ParagraphPlugin from '@ckeditor/ckeditor5-paragraph/src/paragraph';

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
    data () {
      return {
        valueInput: this.value,

        editors: {
          classic: ClassicEditor
        },

        editorConfig: {
          readonly: false,

          //plugins: [
            //EssentialsPlugin,
            //BoldPlugin,
            //ItalicPlugin,
            //LinkPlugin,
            //ParagraphPlugin
          //],

          // Run the editor with the German UI.
          language: 'ru',
          toolbar:  ['heading', '|', 'bold', 'italic', 'link', 'bulletedList', 'numberedList', 'blockQuote', '|'],

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
