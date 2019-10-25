<template>
  <div class="uk-form-horizontal not-stacked">
    <div>
      <label v-text="label || placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="label || placeholder"/>

      <div class="uk-form-controls uk-form-controls-text uk-text-right">
        <label class="uk-display-block">
          <input class="pos-checkbox-switch"
                 :disabled="!editable"
                 v-model.number="valueInputBoolean"
                 :true-value="1"
                 :false-value="0"
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
      value:       {default: 1},
      label:       {
        default: '',
        type:    String
      },
      placeholder: {
        default: '',
        type:    String
      },
      editable:    {default: 1}
    },

    data () {
      return {
        valueInputBoolean: this.value,
        //valueInputBoolean: Number(this.value),
        valid:             true
      }
    },

    computed: {

      valueInput () {
        return Number(this.valueInputBoolean)
      },

      isChanged () {
        return this.valueInputBoolean !== this.value
      }
    },

    methods: {

      update () {
        //this.valueInputBoolean = !this.valueInputBoolean
        this.$emit('change', this.isChanged)
        this.$emit('value', this.valueInput)
      }
    }
  }
</script>
