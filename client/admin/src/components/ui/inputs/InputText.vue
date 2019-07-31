<template>
  <div class="uk-margin">
    <div class="uk-inline">
      <span class="uk-form-icon uk-form-icon-flip"
            uk-icon="icon: lock"></span>
      <input class="uk-input"
             v-model="value"
             type="text"
             :placeholder="placeholder">
    </div>
  </div>
</template>

<script>
  export default {
    name: 'InputText',

    props: {

      value:       {
        default: null,
        type:    String
      },
      placeholder: {
        default: null,
        type:    String
      }
    },

    data () {
      return {}
    },

    methods: {
      update () {
        this.$emit('update', this.value)
      }
    }
  }
</script>

<style lang="sass"
       scoped></style>
