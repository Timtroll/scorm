<template>
  <li>
    <div class="uk-form-horizontal uk-overflow-hidden">
      <div>
        <label class="uk-form-label uk-text-truncate"
               v-if="label"
               v-text="label"/>

        <div class="uk-form-controls">
          <div class="uk-grid-small"
               uk-grid>
            <div class="uk-width-expand"
                 uk-form-custom="target: > * > span:first-child">

              <select v-model="valueInput"
                      :disabled="readonly === 1"
                      @change="update">

                <option v-for="item in selected2"
                        :value="item[0]">{{ item[1] }}
                </option>
              </select>

              <button class="uk-button pos-button-select"
                      :class="validate"
                      :disabled="readonly === 1"
                      type="button"
                      tabindex="-1">
                <span/>
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
  </li>
</template>

<script>

export default {
  name: 'InputSelect2',

  props: {

    value: {
      default: '',
      type:    [String, Number]
    },

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

    selected:  {},
    selected2: {},

    valuesEditable: {
      default: false,
      type:    Boolean
    },
    readonly:       {default: 0, type: Number},
    required:       {default: 0, type: Number}
  },

  data () {

    return {
      valueInput: this.value
    }
  },

  computed: {

    isChanged () {
      return this.valueInput !== this.value
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
        }
        else {
          validClass = 'uk-form-success'
          this.valid = true
          this.$emit('valid', this.valid)
        }
      }
      return validClass
    },

    update () {
      this.$emit('change', this.isChanged)
      //this.$emit('changeType', this.valueInput)
      this.$emit('value', this.valueInput)
    }

  }
}
</script>
