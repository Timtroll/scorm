<template>
  <ul class="pos-list">
    <li v-for="(item, index) in data"
        :key="index">
      <component v-bind:is="item.component"
                 :value="item.value"
                 :values="item.values"
                 :editable="item.editable"
                 :placeholder="labels[index]">
      </component>
    </li>
  </ul>
</template>
<script>

  const InputText       = () => import('../inputs/InputText')
  const InputTextarea   = () => import('../inputs/InputTextarea')
  const InputSelect     = () => import('../inputs/InputSelect')
  const InputNumber     = () => import('../inputs/InputNumber')
  const InputBoolean    = () => import('../inputs/InputBoolean')
  const InputRadio      = () => import('../inputs/InputRadio')
  const InputList       = () => import('../inputs/InputList')
  const InputDoubleList = () => import('../inputs/InputDoubleList')

  export default {
    name:       'List',
    components: {InputTextarea, InputText, InputSelect, InputNumber, InputBoolean, InputRadio, InputList, InputDoubleList},

    // Закрыть панель при нажатии "ESC"
    created () {
      document.onkeydown = evt => {
        evt = evt || window.event
        if (evt.keyCode === 27) {
          this.$emit('close')
        }
      }
    },

    props: {
      data:   {},
      labels: {}
    },

    data () {
      return {}
    }
  }
</script>
