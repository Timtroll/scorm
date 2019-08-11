<template>
  <form class="uk-display-block uk-width-1-1">

    <ul class="pos-list">
      <li v-if="editedData.label">
        <p class="uk-heading-line uk-text-primary uk-h4">
          <span v-text="editedData.label"></span>
        </p>
      </li>
      <!--editable-->
      <li>
        <InputBoolean
            :value="data.editable"
            @change="dataIsChange.editable = $event"
            @update="editedData.editable = $event"
            :placeholder="$t('list.editable')"></InputBoolean>
      </li>
      <!--name-->
      <li>
        <InputText :value="data.name"
                   :required="true"
                   @change="dataIsChange.name = $event"
                   @update="editedData.name = $event"
                   :placeholder="$t('list.name')"></InputText>
      </li>
      <!--label-->
      <li>
        <InputText :value="data.label"
                   :required="true"
                   @change="dataIsChange.label = $event"
                   @update="editedData.label = $event"
                   :placeholder="$t('list.label')"></InputText>
      </li>
      <!--placeholder-->
      <li>
        <InputText :value="data.placeholder"
                   @change="dataIsChange.placeholder = $event"
                   @update="editedData.placeholder = $event"
                   :placeholder="$t('list.placeholder')"></InputText>
      </li>
      <!--mask-->
      <li>
        <InputText :value="data.mask"
                   @change="dataIsChange.mask = $event"
                   @update="editedData.mask = $event"
                   :placeholder="$t('list.mask')"></InputText>
      </li>
      <!--type-->
      <li>
        <InputSelect :value="data.type"
                     :required="true"
                     :values-editable="false"
                     @change="dataIsChange.type = $event"
                     v-on:update="changeType($event)"
                     :placeholder="$t('list.type')"
                     :values="inputComponents"></InputSelect>
      </li>
      <!--value-->
      <li>
        <transition name="slide-right"
                    mode="out-in"
                    appear>
          <component v-bind:is="component"
                     :value="data.value"
                     :values="data.selected"
                     :placeholder="$t('list.value')">
          </component>
        </transition>
      </li>

    </ul>
    {{dataIsChanged}}
  </form>
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

    mounted () {
      //this.$store.commit('cms_table_update_row', this.editedData)
    },

    data () {
      return {
        component: this.data.type,

        editedData:   {
          editable:    this.data.editable,
          name:        this.data.name,
          label:       this.data.label,
          placeholder: this.data.placeholder,
          mask:        this.data.mask,
          type:        this.data.type,
          value:       this.data.value,
          selected:    this.data.selected
        },
        dataIsChange: {
          editable:    false,
          name:        false,
          label:       false,
          placeholder: false,
          mask:        false,
          type:        false,
          value:       false,
          selected:    false
        }
      }
    },

    computed: {

      dataIsChanged () {
        const dataIsChanged = !Object.values(this.dataIsChange).every(item => !item)
        this.$emit('changed', dataIsChanged)
        return dataIsChanged
      },

      inputComponents () {
        return this.$store.getters.inputComponents
      }
    },

    methods: {

      editData () {
        this.$store.commit('cms_table_update_row', this.editedData)
      },

      changeType (event) {
        this.component = event
      }

    }
  }
</script>
