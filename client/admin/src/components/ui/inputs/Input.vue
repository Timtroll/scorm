<template>
  <div class="uk-form-horizontal">
    <div>
      <label v-text="placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="placeholder"></label>

      <div class="uk-form-controls">
        <div class="uk-inline uk-width-1-1">
          <div class="uk-form-icon uk-form-icon-flip">
            1
          </div>
          <input class="uk-input"
                 :disabled="!editable"
                 :class="statusClass"
                 v-model="value"
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
    name: 'Input',

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
        default: false,
        type:    Boolean
      }
    },

    data () {
      return {}
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
