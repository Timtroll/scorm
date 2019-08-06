<template>
  <div class="uk-form-horizontal not-stacked">
    <div>
      <label v-text="placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="placeholder"></label>

      <div class="uk-form-controls uk-form-controls-text uk-text-right">
        <input v-for="(radio, index) in values" class="pos-checkbox-switch"
               :disabled="!editable"
               :value="valuesInput[index]"
               v-model="valueInput"
               type="radio">
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'InputRadio',

    props: {
      value:       {
        default: null
      },
      values:       {
        default: null
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
        default: false,
        type:    Boolean
      }
    },

    data () {
      return {
        valueInput: this.value
      }
    },

    methods: {

      statusClass () {
        switch (this.stats) {
          case 'loading':
            'loading'
            break
          case 'success':
            'success'
            break
          case 'error':
            'error'
            break

        }
      },

      update () {
        this.$emit('update', this.value)
      }
    }
  }
</script>
