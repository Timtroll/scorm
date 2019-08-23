<template>
  <div class="uk-form-horizontal not-stacked">
    <div>
      <label v-text="label || placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="label || placeholder"></label>

      <div class="uk-form-controls">
        <div class="uk-inline uk-width-1-1">
          <div class="uk-form-icon uk-form-icon-flip">
            <img src="/img/icons/icon__input_number.svg"
                 uk-svg
                 width="18"
                 height="18">
          </div>
          <input class="uk-input"
                 pattern="[0-9]*"
                 inputmode="numeric"
                 :disabled="!editable"
                 :class="validate"
                 v-model.number.trim="valueInput"
                 type="number"
                 @input="update"
                 :placeholder="placeholder">
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'InputNumber',

    props: {

      value:       {},
      label:       {
        default: '',
        type:    String
      },
      status:      { // 'loading' / 'success' / 'error'
        default: '',
        type:    String
      },
      mask:        {
        type: RegExp
      },
      placeholder: {
        default: '',
        type:    String
      },
      editable:    {default: 1}
    },

    data () {
      return {
        valueInput: this.value
      }
    },

    watch: {

      valueInput () {
        if (this.mask) {
          console.log('333')
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
