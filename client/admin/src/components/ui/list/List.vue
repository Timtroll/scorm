<template>
  <ul class="uk-list uk-width-1-1">
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

  const InputText   = () => import('../inputs/InputText')
  const InputSelect = () => import('../inputs/InputSelect')
  const InputNumber = () => import('../inputs/InputNumber')

  export default {
    name:       'List',
    components: {InputText, InputSelect, InputNumber},

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
