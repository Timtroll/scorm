<template>
  <div class="uk-form-horizontal uk-overflow-hidden">
    <div>
      <label v-text="label"
             class="uk-form-label uk-text-truncate"
             v-if="label"></label>

      <div class="uk-form-controls">
        <div class="uk-grid-small"
             uk-grid>
          <div class="uk-width-expand"
               uk-form-custom="target: > * > span:first-child">

            <select v-model="valueInput"
                    :disabled="readonly === 1"
                    @change="update">

              <option v-for="item in inputTypes"
                      :value="item.value">{{item.label}}
              </option>
            </select>

            <button class="uk-button pos-button-select"
                    :class="validate"
                    :disabled="readonly === 1"
                    type="button"
                    tabindex="-1">
              <span></span>
              <img src="/img/icons/icon_arrow__down.svg"
                   uk-svg
                   width="14"
                   height="14">
            </button>
          </div>

        </div>

      </div>
    </div>

  </div>
</template>

<script>

  export default {
    name: 'InputType',

    props: {

      value: {},

      label: {
        default: '',
        type:    String
      },

      status: { // 'loading' / 'success' / 'error'
        default: '',
        type:    String
      },

      placeholder: {
        default: '',
        type:    String
      },

      valuesEditable: {
        default: false,
        type:    Boolean
      },
      readonly:       {default: 0, type: Number},
      required:       {default: 0, type: Number}
    },

    data () {

      return {
        valueInput:  this.value,
        valuesInput: this.inputTypes,
        editValues:  false
      }
    },

    watch: {

      valuesInput () {

        // Проверка на наличие Value in Values
        const value         = this.valueInput,
              values        = this.valuesInput,
              valueInValues = values.includes(value)

        if (!valueInValues) {
          this.valueInput = ''
        }

        this.update()
      }
    },

    computed: {

      inputTypes () {
        return this.$store.getters.inputComponents
      },

      isChanged () {
        return this.valueInput !== this.value || JSON.stringify(this.valuesInput) !== JSON.stringify(this.values)
      },

      notEmptyEditValues () {
        const des       = this.valuesInput || []
        const defFilter = [...new Set(des)]
        return defFilter.filter(Boolean).sort()
      }

    },

    methods: {

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
      },

      update () {
        this.$emit('change', this.isChanged)
        this.$emit('value', this.valueInput)
      }

    }
  }
</script>
