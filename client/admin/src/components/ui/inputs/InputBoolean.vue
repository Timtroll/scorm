<template>
  <div class="uk-form-horizontal not-stacked">
    <div>
      <label v-text="placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="placeholder"></label>

      <div class="uk-form-controls uk-form-controls-text uk-text-right">
        <label class="uk-display-block">
          <input class="pos-checkbox-switch"
                 :disabled="!editable"
                 v-model="valueInputBoolean"
                 @input="update"
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
        valueInputBoolean: this.value,
        valid:      true
      }
    },

    computed: {

      valueInput () {
        return Number(this.valueInputBoolean)
      },

      isChanged () {
        return this.valueInput !== this.value
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
