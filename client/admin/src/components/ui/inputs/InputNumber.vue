<template>
  <div class="uk-form-horizontal not-stacked">
    <div>
      <label v-text="placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="placeholder"></label>

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
                 :class="statusClass"
                 v-model.number="valueInput"
                 type="text"
                 @blur="update"
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
