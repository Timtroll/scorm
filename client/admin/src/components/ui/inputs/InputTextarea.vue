<template>
  <div class="uk-form-horizontal">
    <div>
      <label v-text="placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="placeholder"></label>

      <div class="uk-form-controls">
        <textarea class="uk-textarea pos-textarea"
                  rows="2"
                  :disabled="!editable"
                  :class="statusClass"
                  v-model="valueInput"
                  @blur="update"
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
