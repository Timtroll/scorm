<template>
  <ul class="uk-list uk-width-1-1">
    <li v-for="(item, index) in data"
        :key="index">
      <Input :value="item.val"
                 :editable="item.editable"
                 :placeholder="labels[index]">
      </Input>
    </li>
  </ul>
</template>
<script>

  import Input from '../inputs/Input'

  export default {
    name:       'List',
    components: {Input},

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
