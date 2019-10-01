<template>
  <div class="pos-card">

    <!--header-->
    <div class="pos-card-header">

      <!--headerLeft-->
      <a class="pos-card-header-item link"
         :class="{'uk-text-danger' : editPanel_large}"
         @click.prevent="toggleSize">

        <img src="/img/icons/icon__expand.svg"
             uk-svg
             width="20"
             height="20"
             v-if="!editPanel_large">

        <img src="/img/icons/icon__collapse.svg"
             uk-svg
             width="20"
             height="20"
             v-else>
      </a>

      <!--header settings-->
      <div class="pos-card-header--content"></div>
      <!--<div class="pos-card-header&#45;&#45;content"-->
      <!--     v-text="editedData.label"></div>-->

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

    <!--settings-->
    <div class="pos-card-body">
      <form class="pos-card-body-middle uk-position-relative uk-width-1-1">

        <ul class="pos-list"
            v-if="data.length > 0">
          <li v-for="(item, index) in data"
              :key="index">
            <component v-bind:is="item.type"
                       :value="item.value"
                       :selected="item.selected"
                       :required="true"
                       v-focus
                       :mask="item.mask"
                       :label="item.label"
                       :editable="item.editable"
                       :placeholder="item.placeholder">
            </component>
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

      <!--header settings-->
      <div class="pos-card-header--content"></div>

      <div class="pos-card-header-item">
        <!--<button class="uk-button-success uk-button uk-button-small"-->
        <!--        @click.prevent="action"-->
        <!--        :disabled="!isValid">-->
        <!--  <img src="/img/icons/icon__save.svg"-->
        <!--       uk-svg-->
        <!--       width="14"-->
        <!--       height="14">-->

        <!--  <span class="uk-margin-small-left"-->
        <!--        v-text="$t('actions.add')"-->
        <!--        v-if="add"></span>-->
        <!--  <span class="uk-margin-small-left"-->
        <!--        v-text="$t('actions.save')"-->
        <!--        v-else></span>-->
        <!--</button>-->
      </div>

    </div>
  </div>

</template>

<script>

  //import {mergeObject} from './../../../store/methods'

  export default {

    name: 'List',

    components: {
      Loader:          () => import('../icons/Loader'),
      InputTextarea:   () => import('../inputs/InputTextarea'),
      InputText:       () => import('../inputs/InputText'),
      InputCKEditor:   () => import('../inputs/InputCKEditor'),
      InputSelect:     () => import('../inputs/InputSelect'),
      InputNumber:     () => import('../inputs/InputNumber'),
      InputBoolean:    () => import('../inputs/InputBoolean'),
      InputRadio:      () => import('../inputs/InputRadio'),
      InputDoubleList: () => import('../inputs/InputDoubleList'),
      inputDateTime:   () => import('../inputs/inputDateTime'),
      InputCode:       () => import('../inputs/InputCode')
    },

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

      data: {
        //type:     Array,
        required: true
      },

      add: {
        type:    Boolean,
        default: false
      },

      parent: {
        type: Number
      },

      labels: {}
    },

    beforeDestroy () {
      this.$store.commit('editPanel_data', null)
    },

    data () {
      return {
        dataNew: {}
      }
    },

    computed: {

      // Проверка на уникальность поля 'name' в таблице
      //tableNames () {
      //
      //  if (!this.add) {
      //    const index = this.usedNames.indexOf(this.currentName)
      //    if (index !== -1) this.usedNames.splice(index, 1)
      //  }
      //
      //  return this.usedNames.includes(this.editedData.name)
      //},

      // широкая / узкая панель редактирования
      editPanel_large () {
        return this.$store.getters.editPanel_large
      },

      // лоадер
      loader () {
        return this.$store.getters.editPanel_status
      },

      //// если данные в форме изменились
      //dataIsChanged () {
      //  if (this.dataIsChange) {
      //    return !Object.values(this.dataIsChange).every(item => !item)
      //  }
      //},

      // список компонентов для ввода
      inputComponents () {
        return this.$store.getters.inputComponents
      }

      ////
      //parentId () {
      //  return this.rowData.parent || this.parent || 0
      //}
    },

    methods: {

      toggleSize () {
        this.$store.commit('editPanel_size', !this.editPanel_large)
      },

      close () {
        this.$emit('close')
        this.$store.commit('card_right_show', false)
      },

      changeType (event) {
        this.component       = event
        this.editedData.type = event
      }

    }
  }

</script>
