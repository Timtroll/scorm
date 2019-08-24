<template>
  <div class="">
    <div>
      <label v-text="label || placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="label || placeholder"></label>

      <div class="uk-form-controls">
        <div :class="{'uk-position-cover': fullSize}"
             class="uk-background-default uk-flex uk-flex-column"
             style="z-index: 10">
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
                    ref='codeEditor'
                    @init="editorInit"
                    lang="html"
                    :options="editorOptions"
                    theme="dracula"
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

  export default {
    name: 'InputCode',

    components: {
      editor
      //editor: require('vue2-ace-editor')
    },

    props: {
      value:       {
        default: ''
      },
      label:       {
        default: '',
        type:    String
      },
      status:      { // 'loading' / 'success' / 'error'
        default: '',
        type:    String
      },
      placeholder: {
        default: '',
        type:    String
      },
      editable:    {default: 1}
    },

    data () {
      return {
        valueInput:    this.value,
        fullSize:      false,
        editorOptions: {
          highlightActiveLine:       true,
          readOnly:                  false,
          showInvisibles:            false,
          tabSize:                   4,
          enableBasicAutocompletion: true,
          enableLiveAutocompletion:  true,
          showPrintMargin:           false
        }

      }
    },

    created () {
      if (this.editable === 0) {
        this.editorOptions.readOnly = true
      }
    },

    watch: {

      valueInput () {
        this.update()
      },

      editable () {
        this.editorOptions.readOnly = this.editable === 0
        if (this.$refs.codeEditor.editor) {
          this.$refs.codeEditor.editor.$readOnly = (Boolean(!this.editable))
        }
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

        //language extension prerequsite...
        require('brace/ext/language_tools')
        require('brace/ext/beautify')
        require('brace/ext/emmet')
        require('brace/ext/error_marker')
        require('brace/ext/searchbox')
        require('brace/ext/whitespace')
        require('brace/ext/statusbar')

        //language
        require('brace/mode/html')
        require('brace/mode/javascript')
        require('brace/mode/sass')
        require('brace/mode/scss')
        require('brace/mode/css')
        require('brace/mode/perl')

        // theme
        require('brace/theme/dracula')

        // snippet
        require('brace/snippets/javascript')
        require(['emmet/emmet'], (data) => {
          window.emmet = data.emmet
        })
      },

      update () {
        this.$emit('change', this.isChanged)
        this.$emit('value', this.valueInput)
      }
    }
  }
</script>
