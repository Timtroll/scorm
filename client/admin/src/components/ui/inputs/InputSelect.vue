<template>
  <div class="uk-form-horizontal">
    <div>
      <label v-text="placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="placeholder"></label>

      <div class="uk-form-controls">
        <div class="uk-grid-small"
             uk-grid>
          <div class="uk-width-expand"
               uk-form-custom="target: > * > span:first-child">
            <select v-model.number="valueInput"
                    :disabled="!editable"
                    @change="update">
              <option value="item[0]"
                      v-for="item in valuesInput">{{item[1]}}
              </option>

            </select>
            <button class="uk-button uk-height-1-1 uk-button-default uk-width-1-1 uk-flex uk-flex-between uk-flex-middle"
                    :class="statusClass"
                    type="button"
                    tabindex="-1">
              <span></span>
              <img src="/img/icons/icon_arrow__down.svg"
                   uk-svg
                   width="14"
                   height="14">
            </button>
          </div>
          <div class="uk-width-auto">
            <button type="button"
                    class="uk-button uk-button-primary">
              <img src="/img/icons/icon__edit.svg"
                   width="16"
                   height="16"
                   uk-svg>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'InputSelect',

    props: {

      value:       {
        default: null
      },
      values:      {
        type: Array
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
        valueInput:  this.value,
        valuesInput: this.values
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
