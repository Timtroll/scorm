<template>
  <div class="uk-form-horizontal">
    <div>
      <label v-text="placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="placeholder"></label>

      <div class="uk-form-controls">
        <div class="uk-inline uk-width-1-1">
          <div class="uk-form-icon uk-form-icon-flip">
            <img src="/img/icons/icon__input_text.svg"
                 uk-svg
                 width="18"
                 height="18">
          </div>
          <input class="uk-input"
                 :disabled="!editable"
                 :class="validate"
                 v-model="valueInput"
                 type="text"
                 @input="update"
                 :placeholder="placeholder">
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'InputText',

    props: {
      value:       {
        default: null
      },
      placeholder: {
        default: null,
        type:    String
      },
      editable:    {
        default: true,
        type:    Boolean
      },
      required:    {
        default: false,
        type:    Boolean
      }
    },

    data () {
      return {
        valueInput: this.value,
        valid:      true
      }
    },

    computed: {

      isChanged () {
        return this.valueInput !== this.value
      },

      validate () {

        let validClass = null
        if (this.required) {
          if (!this.valueInput || this.valueInput.length < 3) {
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
        this.$emit('update', this.valueInput)
      }
    }
  }
</script>
