<template>
  <div class="">
    <div>
      <label v-text="label || placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="label || placeholder"></label>

      <div class="uk-form-controls">
        <div :class="{'uk-position-cover': fullSize}"
             class="uk-background-default uk-flex uk-position-z-index uk-flex-column">
          <div class="uk-flex-none uk-text-right uk-padding-xsmall pos-border-bottom">
            <a class="pos-card-header-item link"
               :class="{'uk-text-danger' : fullSize}"
               @click.prevent="fullSize = !fullSize">

              <img src="/img/icons/icon__expand.svg"
                   uk-svg
                   width="20"
                   height="20"
                   v-if="!fullSize">

              <img src="/img/icons/icon__collapse.svg"
                   uk-svg
                   width="20"
                   height="20"
                   v-else>
            </a>
          </div>
          <div class="uk-flex-1">
            <editor v-model="valueInput"
                    @init="editorInit"
                    lang="html"
                    theme="chrome"
                    width="100%"
                    :height="editorHeight"></editor>
          </div>
        </div>

      </div>
    </div>
  </div>
</template>

<script>

  import editor from 'vue2-ace-editor'
  import 'brace/ext/language_tools'

  import  'brace/ext/beautify'
  import  'brace/ext/emmet'
  import  'brace/ext/error_marker'
  import  'brace/ext/searchbox'
  import  'brace/ext/settings_menu'
  import  'brace/ext/whitespace'
  import  'brace/ext/statusbar'

  import  'brace/mode/html'
  import  'brace/mode/javascript'  //language
  import  'brace/mode/sass'
  import  'brace/mode/scss'
  import  'brace/mode/css'
  import  'brace/mode/perl'

  import  'brace/theme/chrome'
  import  'brace/snippets/javascript' //sni

  export default {
    name: 'InputCode',

    components: {
      editor
      //editor: require('vue2-ace-editor')
    },

    props: {
      value:       {
        default: null
      },
      label:       {
        default: null,
        type:    String
      },
      status:      { // 'loading' / 'success' / 'error'
        default: null,
        type:    String
      },
      placeholder: {
        default: null,
        type:    String
      },
      editable:    {
        default: true,
        type:    Boolean
      }
    },

    data () {
      return {
        valueInput: this.value,
        fullSize:   false

      }
    },

    watch: {
      valueInput () {
        this.update()
      },
      fullSize () {
        this.editorInit()
      }
    },

    computed: {

      editorHeight () {
        return (this.fullSize) ? '100%' : '300'
      },

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

      editorInit: () => {
        //require('brace/ext/language_tools') //language extension prerequsite...
        //require('brace/ext/beautify')
        //require('brace/ext/emmet')
        //require('brace/ext/error_marker')
        //require('brace/ext/searchbox')
        //require('brace/ext/settings_menu')
        //require('brace/ext/whitespace')
        //require('brace/ext/statusbar')
        //
        //require('brace/mode/html')
        //require('brace/mode/javascript')    //language
        //require('brace/mode/sass')
        //require('brace/mode/scss')
        //require('brace/mode/css')
        //require('brace/mode/perl')
        //
        //require('brace/theme/chrome')
        //require('brace/snippets/javascript') //snippet
      },

      update () {
        this.$emit('change', this.isChanged)
        this.$emit('value', this.valueInput)
      }
    }
  }
</script>
