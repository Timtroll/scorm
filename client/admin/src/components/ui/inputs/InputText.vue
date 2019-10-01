<template>
  <div class="uk-form-horizontal">
    <div>
      <label v-text="label"
             class="uk-form-label uk-text-truncate"
             v-if="label"></label>

      <div class="uk-form-controls">
        <div class="uk-inline uk-width-1-1">
          <div class="uk-form-icon uk-form-icon-flip">
            <img src="/img/icons/icon__input_text.svg"
                 uk-svg
                 width="18"
                 height="18">
          </div>
          <input class="uk-input"
                 :disabled="readonly === 1"
                 :class="validate"
                 v-model.trim="valueInput"
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
      value:       '',
      name:        '',
      label:       {
        default: '',
        type:    String
      },
      placeholder: {
        default: '',
        type:    String
      },
      readonly:    {default: 0, type: Number},
      required:    {default: 0, type: Number},
      mask:        {
        type: RegExp
      }

    },

    data () {
      return {
        valueInput: this.value,
        valid:      true
      }
    },

    watch: {

      valueInput () {
        if (this.mask) {
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
