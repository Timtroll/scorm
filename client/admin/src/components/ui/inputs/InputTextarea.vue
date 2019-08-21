<template>
  <div class="uk-form-horizontal">
    <div>
      <label v-text="label || placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="label || placeholder"></label>

      <div class="uk-form-controls">
        <textarea class="uk-textarea pos-textarea"
                  rows="3"
                  :disabled="!editable"
                  :class="validate"
                  v-model="valueInput"
                  @change="update"
                  :placeholder="placeholder"></textarea>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'InputTextarea',

    props: {
      value:       {
        default: null
      },
      label: {
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
