<template>
  <li>
    <div class="uk-form-controls uk-margin-top">
      <EditorJs :data="valueInput"
                @update="update($event)"
                @ready="onReady"/>
    </div>
  </li>
</template>

<script>

export default {
  name: 'InputEditorJs',

  components: {
    EditorJs: () => import(/* webpackChunkName: "EditorJs" */ '@/components/ui/editor-js/EditorJs')
  },

  props: {

    value: {},

    label: {
      default: '',
      type:    String
    },

    status: { // 'loading' / 'success' / 'error'
      default: '',
      type:    String
    },

    placeholder: {
      default: '',
      type:    String
    },

    editable: {default: 1}
  },

  data () {
    return {
      valueInput: this.initData(this.value)
    }
  },

  mounted () {
    setTimeout(() => {
      //this.initData(this.value)
    }, 100)
  },

  computed: {

    onlyText () {
      if (!this.valueInput) return
      if (!this.valueInput.block) return

      return this.valueInput.block
                 .map(i => i.type === 'paragraph')
    }

    //isChanged () {
    //  return this.valueInput !== this.value
    //},
    //
    //validate () {
    //
    //  let validClass = null
    //  if (this.required) {
    //    if (!this.valueInput && this.valueInput.length < 1) {
    //      validClass = 'uk-form-danger'
    //      this.valid = false
    //      this.$emit('valid', this.valid)
    //    }
    //    else {
    //      validClass = 'uk-form-success'
    //      this.valid = true
    //      this.$emit('valid', this.valid)
    //    }
    //  }
    //  return validClass
    //}
  },

  methods: {

    initData (data) {
      if (!data) return

      console.log('1')
      if (data.constructor === Object) {
        console.log('Object')
        return data

      }
      else if (data.constructor === String) {
        console.log('String')
        return {
          blocks: [{
            type: 'paragraph',
            data: {text: this.value}
          }]
        }
      }
    },

    onReady () {
      console.log('ready')
    },
    onChange () {
      console.log('changed')
    },

    update (data) {
      this.isChanged  = true
      this.valueInput = data
      this.$emit('change', this.isChanged)
      this.$emit('value', this.valueInput)
    }
  }
}
</script>
