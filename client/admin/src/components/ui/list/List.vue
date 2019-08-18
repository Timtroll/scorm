<template>
  <div class="pos-card">

    <!--header-->
    <div class="pos-card-header">

      <!--headerLeft-->
      <a class="pos-card-header-item link"
         :class="{'uk-text-danger' : rightPanelSize}"
         @click.prevent="toggleSize">

        <img src="/img/icons/icon__expand.svg"
             uk-svg
             width="20"
             height="20"
             v-if="!rightPanelSize">

        <img src="/img/icons/icon__collapse.svg"
             uk-svg
             width="20"
             height="20"
             v-else>
      </a>

      <!--header content-->
      <div class="pos-card-header--content"
           v-text="this.editedData.label"></div>

      <!--headerRight-->
      <div class="pos-card-header-item">
        <a class="pos-card-header-item uk-text-danger link"
           @click.prevent="close">
          <img src="/img/icons/icon__close.svg"
               uk-svg
               width="16"
               height="16">
        </a>
      </div>
    </div>

    <!--content-->
    <div class="pos-card-body">
      <form @change.prevent="editData"
            class="pos-card-body-middle uk-position-relative uk-width-1-1">

        <ul class="pos-list">

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
                         @change="dataIsChange.value = $event"
                         @update="editedData.value = $event"
                         :placeholder="$t('list.value')">
              </component>
            </transition>
          </li>

        </ul>

        <!--loading-->
        <transition name="fade">
          <div class="pos-card-loader"
               v-if="loader === 'loading'">
            <div>
              <loader :width="40"
                      :height="40"></Loader>
              <div class="uk-margin-small-top"
                   v-text="$t('actions.loading')"></div>
            </div>
          </div>
        </transition>
      </form>
    </div>

    <!--footer-->
    <div class="pos-card-footer">

      <!--header content-->
      <div class="pos-card-header--content">
      </div>
      <div class="pos-card-header-item">
        <button class="uk-button-success uk-button uk-button-small"
                @click.prevent="set_save"
                :disabled="!dataIsChanged">
          <img src="/img/icons/icon__save.svg"
               uk-svg
               width="14"
               height="14">
          <span class="uk-margin-small-left"
                v-text="$t('actions.save')"></span>
        </button>
      </div>

    </div>
  </div>

</template>

<script>

  import Card from '../card/Card'

  const Loader          = () => import('../icons/Loader')
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
    components: {Card, Loader, InputTextarea, InputText, InputSelect, InputNumber, InputBoolean, InputRadio, InputList, InputDoubleList},

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
      this.$emit('title', this.editedData.label)
    },

    beforeDestroy () {
      this.$store.commit('cms_table_row_data', null)
    },

    data () {
      return {

        component:  this.data.type,
        editedData: this.data,

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

      rightPanelSize () {
        return this.$store.getters.rightPanelSize
      },

      //dataForSave () {
      //
      //  const newData    = this.editedData
      //  newData.selected = JSON.stringify(newData.selected)
      //  newData.value    = JSON.stringify(newData.value)
      //  return newData
      //
      //},

      //dataForSave: {
      //
      //  get: () => {
      //    const newData    = this.editedData
      //    newData.selected = JSON.stringify(newData.selected)
      //    newData.value    = JSON.stringify(newData.value)
      //    return newData
      //  },
      //  set: (newData) => {
      //    this.$store.dispatch('editTableRow', newData)
      //  }
      //
      //},

      loader () {
        return this.$store.getters.queryRowStatus
      },

      dataIsChanged () {
        return !Object.values(this.dataIsChange).every(item => !item)
      },

      inputComponents () {
        return this.$store.getters.inputComponents
      }
    },

    methods: {

      toggleSize () {
        this.$store.commit('right_panel_size', !this.rightPanelSize)
      },

      close () {
        this.$store.commit('cms_table_row_show', false)
      },

      set_save () {
        const data    = this.editedData
        data.value    = JSON.stringify(data.value)
        data.selected = JSON.stringify(data.selected)

        console.log(data)
        this.$store.dispatch('editTableRow', data)
      },

      editData () {
        //this.$store.commit('cms_table_update_row', this.editedData)
      },

      changeType (event) {
        this.component = event
      }

    }
  }
</script>
