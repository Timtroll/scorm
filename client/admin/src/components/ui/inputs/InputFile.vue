<template>
  <li>
    <div class="uk-form-horizontal">
      <div>
        <label v-text="label"
               class="uk-form-label uk-text-truncate"
               v-if="label"/>

        <div class="uk-form-controls">
          <div class="uk-inline uk-width-1-1">
            <div class="uk-form-icon uk-form-icon-flip">
              <img src="/img/icons/icon__input_text.svg"
                   uk-svg
                   width="18"
                   height="18">
            </div>
            <input class="uk-input"
                   multiple
                   :class="validate"
                   type="file"
                   @change="previewFiles"
                   :placeholder="placeholder">
          </div>
        </div>
      </div>
    </div>
  </li>
</template>

<script>
import files from '@/api/upload/files'

export default {
  name: 'InputFile',

  props: {

    value:       [],
    name:        '',
    label:       {
      default: '',
      type:    String
    },
    placeholder: {
      default: '',
      type:    String
    },
    readonly:    {default: 0, type: Number},
    required:    {default: 0, type: Number}

  },

  data () {
    return {
      valueInput: this.value,
      valid:      true,
      files:      []
    }
  },

  watch: {},

  computed: {
    isChanged () {
      return this.valueInput !== this.value
    }
  },

  methods: {

    previewFiles (event) {
      this.files = event.target.files
      files.upload(event.target.files)
      console.log(event.target.files)
      console.log('this.files', this.files)
    },

    update () {
      this.$emit('change', this.isChanged)
      //this.$emit('value', this.valueInput)
    }
  }
}
</script>
