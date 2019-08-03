<template>
  <ul class="uk-list uk-width-1-1">
    <li v-for="(item, index) in data"
        :key="index">
      <InputText :value="item.val"
                 :editable="item.editable"
                 :placeholder="labels[index]">
      </InputText>
    </li>
  </ul>
</template>
<script>

  import InputText from '../inputs/InputText'

  export default {
    name:       'List',
    components: {InputText},
    props:      {
      data:   {},
      labels: {}
    },

    data () {
      return {}
    }
  }
</script>
