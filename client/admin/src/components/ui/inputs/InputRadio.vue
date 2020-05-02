<template>
  <li>
    <div class="uk-form-horizontal uk-overflow-hidden">
      <div>
        <label v-text="label || placeholder"
               class="uk-form-label uk-text-truncate"
               v-if="label || placeholder"/>

        <div class="uk-form-controls uk-form-controls-text">

          <label class="uk-width-1-1 uk-flex uk-flex-middle uk-grid-collapse pos-radio-label"
                 uk-grid=""
                 v-for="(radio, index) in selected">

            <input class="pos-checkbox-switch small"
                   :disabled="readonly === 1"
                   v-model="valueInput"
                   :value="radio"
                   @change="update"
                   type="radio">

            <div class="uk-width-expand uk-margin-small-left">
              <span class="uk-text-truncate"
                    v-text="radio"/>
            </div>
          </label>

        </div>
      </div>
    </div>
  </li>
</template>

<script>

  export default {
    name: 'InputRadio',

    props: {
      value:       '',
      name:        '',
      label:       {
        default: '',
        type:    String
      },
      placeholder: {
        default: '',
        type:    String
      },
      selected:    {},
      readonly:    {default: 0, type: Number},
      required:    {default: 0, type: Number},
      mask:        {
        type: RegExp
      }

    },

    data () {
      return {
        valueInput: this.value,
        valid:      true
      }
    },

    computed: {

      isChanged () {
        return this.valueInput !== this.value
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
