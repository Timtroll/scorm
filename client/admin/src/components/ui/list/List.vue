<template>
  <ul class="pos-list">
    <li>
      <InputText :value="data.name"
                 :placeholder="'Системное название'"></InputText>
    </li>
    <li>
      <InputText :value="data.label"
                 :placeholder="'Рашифровка'"></InputText>
    </li>
    <li>
      <InputText :value="data.placeholder"
                 :placeholder="'Placeholder'"></InputText>
    </li>
    <li>
      <InputText :value="data.mask"
                 :placeholder="'Маска'"></InputText>
    </li>
    <li>
      <InputSelect :value="data.type"
                   :values-editable="false"
                   v-on:update="changeType($event)"
                   :placeholder="'Тип'"
                   :values="inputComponents"></InputSelect>
    </li>
    <li>
      <transition name="slide-right"
                  mode="out-in"
                  appear>
        <component v-bind:is="component"
                   :value="data.value"
                   :placeholder="'Значение'">
        </component>
      </transition>
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
      return {
        component: this.data.type
      }
    },

    computed: {

      inputComponent () {
        return this.data.type
      },

      inputComponents () {
        return this.$store.getters.inputComponents
      }
    },

    methods: {

      changeType (event) {
        this.component = event
        console.log(event)
      }

    }
  }
</script>
