<template>
  <li>
    <div class="uk-form-horizontal not-stacked">
      <div>
        <label v-text="label || placeholder"
               class="uk-form-label uk-text-truncate"
               v-if="label || placeholder"/>

        <div class="uk-form-controls uk-form-controls-text uk-text-right">
          <label class="uk-display-block">
            <input class="pos-checkbox-switch"
                   :disabled="disabled"
                   v-model.number="valueInputBoolean"
                   :true-value="1"
                   :false-value="0"
                   @change="update"
                   type="checkbox">
          </label>
        </div>
      </div>
    </div>
  </li>
</template>

<script>
  export default {
    name: 'InputBoolean',

    props: {
      value:       {default: 1},
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
      required:    {default: 0, type: Number}
    },

    data () {
      return {
        valueInputBoolean: this.value,
        //valueInputBoolean: Number(this.value),
        valid:             true
      }
    },

    computed: {

      disabled () {
        if (this.name !== 'readonly') {
          return !this.readonly
        }
      },

      valueInput () {
        return Number(this.valueInputBoolean)
      },

      isChanged () {
        return this.valueInputBoolean !== this.value
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
