<template>
  <div class="">
    <div>
      <label v-text="label || placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="label || placeholder"/>

      <div class="uk-form-controls">
        <div :class="{'uk-position-cover': fullSize}"
             class="uk-background-default uk-flex uk-flex-column"
             style="z-index: 10">
          <div class="uk-flex-none uk-text-right uk-padding-xsmall pos-border-bottom uk-flex uk-flex-between uk-flex-middle">

            <!--Выбор языка-->
            <select v-model="lang"
                    class="">
              <option v-for="item in langSelect"
                      :value="item">{{item}}
              </option>
            </select>

            <!--<div uk-form-custom="target: > * > span:first-child"-->
            <!--     class="uk-margin-small-right">-->

            <!--  <select v-model="lang"-->
            <!--          class="uk-select uk-button-small">-->
            <!--    <option v-for="item in langSelect"-->
            <!--            :value="item">{{item}}-->
            <!--    </option>-->
            <!--  </select>-->

            <!--  <button class="uk-button-small uk-button uk-button-default"-->
            <!--          type="button"-->
            <!--          tabindex="-1">-->

            <!--    <span class="uk-margin-small-right"/>-->
            <!--    <img src="/img/icons/icon_arrow__down.svg"-->
            <!--         uk-svg-->
            <!--         width="12"-->
            <!--         height="12">-->
            <!--  </button>-->
            <!--</div>-->

            <!--размер окна-->
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
                    :lang="lang"
                    :options="editorOptions"
                    width="100%"
                    :height="editorHeight"/>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

  //import brace from 'brace'
  import editor from 'vue2-ace-editor'

  export default {
    name: 'InputCode',

    components: {
      //editor
      editor: () => import(/* webpackChunkName: "vue2-ace-editor" */ 'vue2-ace-editor')
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
        lang:          'html',
        langSelect:    [
          'html',
          'yaml',
          'jade',
          'pig',
          'markdown',
          'latex',
          'javascript',
          'xml',
          'json',
          'smarty',
          'handlebars',
          'css',
          'less',
          'sass',
          'scss',
          'perl',
          'php'
        ],
        valueInput:    this.value,
        fullSize:      false,
        editorOptions: {
          highlightActiveLine:       true,
          readonly:                  false,
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
        this.editorOptions.readonly = true
      }
    },

    watch: {

      valueInput () {
        this.update()
      },

      editable () {

        this.editorOptions.readonly = this.editable === 0

        if (this.$refs.codeEditor.editor) {
          this.$refs.codeEditor.editor.$readonly = (Boolean(!this.editable))
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
        import('brace/ext/language_tools')
        import('brace/ext/beautify')
        require('brace/ext/emmet') //     "emmet": "git+https://github.com/cloud9ide/emmet-core.git#41973fcc70392864c7a469cf5dcd875b88b93d4a",

        import('brace/ext/error_marker')
        import('brace/ext/searchbox')
        import('brace/ext/whitespace')
        import('brace/ext/statusbar')

        //language
        import('brace/mode/html')
        import('brace/mode/javascript')
        import('brace/mode/sass')
        import('brace/mode/scss')
        import('brace/mode/less')
        import('brace/mode/css')
        import('brace/mode/perl')
        import('brace/mode/php')
        import('brace/mode/pig')
        import('brace/mode/latex')
        import('brace/mode/xml')
        import('brace/mode/handlebars')
        import('brace/mode/jade')
        import('brace/mode/json')
        import('brace/mode/markdown')
        import('brace/mode/smarty')
        import('brace/mode/yaml')

        //theme
        //import('brace/theme/dracula')

        //snippet
        import('brace/snippets/javascript')
        //require(['emmet/emmet'], (data) => {
        //  window.emmet = data.emmet
        //})
      },

      update () {
        this.$emit('change', this.isChanged)
        this.$emit('value', this.valueInput)
      }
    }
  }
</script>
