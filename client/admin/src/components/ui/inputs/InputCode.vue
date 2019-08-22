<template>
  <div class="">
    <div>
      <label v-text="label || placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="label || placeholder"></label>

      <div class="uk-form-controls">
        <editor v-model="valueInput"
                @init="editorInit"
                lang="html"
                theme="chrome"
                width="100%"
                height="400"></editor>

      </div>
    </div>
  </div>
</template>

<script>

  export default {
    name: 'InputCode',

    components: {
      editor: require('vue2-ace-editor')
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
        valueInput: this.value

      }
    },

    watch: {
      valueInput () {
        this.update()
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

      editorInit: function () {
        require('brace/ext/language_tools') //language extension prerequsite...
        require('brace/ext/beautify')
        require('brace/ext/emmet')
        require('brace/ext/error_marker')
        require('brace/ext/searchbox')
        require('brace/ext/settings_menu')
        require('brace/ext/whitespace')
        require('brace/ext/statusbar')

        require('brace/mode/html')
        require('brace/mode/javascript')    //language
        require('brace/mode/sass')
        require('brace/mode/scss')
        require('brace/mode/css')
        require('brace/mode/perl')

        require('brace/theme/chrome')
        require('brace/snippets/javascript') //snippet
      },

      update () {
        this.$emit('change', this.isChanged)
        this.$emit('value', this.valueInput)
      }
    }
  }
</script>
