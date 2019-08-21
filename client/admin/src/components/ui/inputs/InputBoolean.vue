<template>
  <div class="uk-form-horizontal not-stacked">
    <div>
      <label v-text="label || placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="label || placeholder"></label>

      <div class="uk-form-controls uk-form-controls-text uk-text-right">
        <label class="uk-display-block">
          <input class="pos-checkbox-switch"
                 :disabled="!editable"
                 :checked="valueInputBoolean"
                 @change="update"
                 type="checkbox">
        </label>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'InputBoolean',

    props: {
      value: {
        default: null
      },
      label: {
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
        valueInputBoolean: +this.value || 0,
        valid:             true
      }
    },

    computed: {

      valueInput () {
        return +this.valueInputBoolean
      },

      isChanged () {
        return +this.valueInput !== +this.value
      }
    },

    methods: {

      update () {
        this.valueInputBoolean = !+this.valueInputBoolean
        this.$emit('change', this.isChanged)
        this.$emit('value', this.valueInput)
      }
    }
  }
</script>
