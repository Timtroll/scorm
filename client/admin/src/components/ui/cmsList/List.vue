<template>
  <div class="pos-card"
       v-touch:swipe="swipeRight">

    <!--header-->
    <div class="pos-card-header">

      <!--headerLeft-->
      <a class="pos-card-header-item link uk-visible@m"
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
      <div class="pos-card-header--content uk-padding-remove"
           ref="listMenu">
        <ListMenu :nav="listMenu"
                  v-if="loader  === 'success' || 'error' && listMenu && listMenu.length > 0"
                  :active="listMenuActiveId"
                  @active-id="setActiveMenuItem($event)"
                  :resize="editPanel_large"/>
      </div>
      <!--<div class="pos-card-header&#45;&#45;content"-->
      <!--     v-text="title"></div>-->

      <!--headerRight-->
      <a class="pos-card-header-item uk-text-danger link"
         @click.prevent="close">
        <img src="/img/icons/icon__close.svg"
             class="uk-button-icon-fix"
             uk-svg
             width="16"
             height="16">
      </a>

    </div>

    <!--Edit FORM-->
    <div class="pos-card-body">
      <form class="pos-card-body-middle uk-position-relative uk-width-1-1">
        <ul class="pos-list main">

          <!--// MAIN-->
          <component v-bind:is="item.type"
                     v-for="(item, index) in dataNew.main"
                     :key="index"
                     :value="item.value"
                     :type="item.type"
                     :name="item.name"
                     :selected="valueSelected"
                     :readonly="notEditable(item.readonly)"
                     :add="item.add"
                     :required="item.required"
                     :mask="item.mask"
                     :label="item.label"
                     :placeholder="item.placeholder"
                     @value="dataNew.main[index].value = $event"
                     @change="dataChanged[index].changed = $event"
                     @clear="clearValue"
                     @changeType="changeType($event)"/>
        </ul>
        <ul class="pos-list">
          <li class="uk-padding-remove uk-flex-1"
              :class="{'uk-hidden': listMenuActiveId !== index}"
              v-for="(group, index) in dataNew.groups">

            <transition name="slide-right"
                        appear
                        mode="out-in">
              <ul class="pos-list"
                  :key="index"
                  v-show="listMenuActiveId === index">

                <component v-bind:is="item.type"
                           v-for="(item, index) in group.fields"
                           :key="index"
                           :value="item.value"
                           :type="item.type"
                           :name="item.name"
                           :selected="valueSelected"
                           :readonly="notEditable(item.readonly)"
                           :add="item.add"
                           :required="item.required"
                           :mask="item.mask"
                           :label="item.label"
                           :placeholder="item.placeholder"
                           @value="group.fields[index].value = $event"
                           @change="dataChanged[index].changed = $event"
                           @clear="clearValue"
                           @changeType="changeType($event)"/>
              </ul>
            </transition>
          </li>
        </ul>

        <!--loading-->
        <transition name="fade">
          <div class="pos-card-loader"
               v-if="loader === 'loading'">
            <div>
              <loader :width="40"
                      :height="40"/>
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
        <button class="uk-button-success uk-button uk-button-small"
                @click.prevent="save"
                :disabled="!dataIsChanged">
          <img src="/img/icons/icon__save.svg"
               uk-svg
               width="14"
               height="14">

          <span class="uk-margin-small-left"
                v-text="$t('actions.add')"
                v-if="add"/>
          <span class="uk-margin-small-left"
                v-text="$t('actions.save')"
                v-else/>
        </button>
      </div>

    </div>
  </div>

</template>

<script>

  import {clone, confirm, unGroupedFields, flatFields} from '../../../store/methods'

  export default {

    name: 'List',

    components: {
      Loader:   () => import(/* webpackChunkName: "loader" */ '../icons/Loader'),
      ListMenu: () => import(/* webpackChunkName: "ListMenu" */ './ListMenu'),

      // inputs
      InputTextarea:   () => import(/* webpackChunkName: "InputTextarea" */ '../inputs/InputTextarea'),
      InputText:       () => import(/* webpackChunkName: "InputText" */ '../inputs/InputText'),
      InputInfo:       () => import(/* webpackChunkName: "InputInfo" */ '../inputs/InputInfo'),
      InputCKEditor:   () => import(/* webpackChunkName: "InputCKEditor" */ '../inputs/InputCKEditor'),
      InputTinyMCE:    () => import(/* webpackChunkName: "InputTinyMCE" */ '../inputs/InputTinyMCE'),
      InputSelect:     () => import(/* webpackChunkName: "InputSelect" */ '../inputs/InputSelect'),
      InputSelected:   () => import(/* webpackChunkName: "InputSelected" */ '../inputs/InputSelected'),
      InputNumber:     () => import(/* webpackChunkName: "InputNumber" */ '../inputs/InputNumber'),
      InputBoolean:    () => import(/* webpackChunkName: "InputBoolean" */ '../inputs/InputBoolean'),
      InputRadio:      () => import(/* webpackChunkName: "InputRadio" */ '../inputs/InputRadio'),
      InputDoubleList: () => import(/* webpackChunkName: "InputDoubleList" */ '../inputs/InputDoubleList'),
      inputDateTime:   () => import(/* webpackChunkName: "inputDateTime" */ '../inputs/inputDateTime'),
      InputCode:       () => import(/* webpackChunkName: "InputCode" */ '../inputs/InputCode'),
      InputType:       () => import(/* webpackChunkName: "InputType" */ '../inputs/InputType')
    },

    // Закрыть панель при нажатии "ESC"
    mounted () {

      document.onkeydown = evt => {
        evt = evt || window.event
        if (evt.keyCode === 27) {
          this.close()
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

      variableTypeField: {
        type:    String,
        default: 'value'
      },

      parent: {
        type: Number
      },

      labels: {}
    },

    async created () {

      //// ширина меню панели редактирования
      //if (this.$refs.listMenu) {
      //  this.listMenuWidth = this.$refs.listMenu.offsetWidth
      //}

      if (this.add) {
        this.dataAdd     = await this.data.filter(item => item.add === true)
        this.dataNew     = await clone(this.dataAdd)
        this.dataChanged = await this.createDataChanged(this.dataAdd)

        console.log('data', this.data)
      } else {
        this.dataNew     = await clone(this.data)
        this.dataChanged = await this.createDataChanged(this.data)
      }

    },

    beforeDestroy () {
      this.$store.commit('editPanel_data', null)
      this.$store.commit('editPanel_add', false)
    },

    data () {
      return {
        listMenuActiveId: 1,
        //listMenuWidth:    null,
        //dataGrouped: [],
        dataNew:          [],
        dataFlat:         [],
        dataChanged:      [],
        dataAdd:          [],
        showSelectedOn:   ['InputSelect', 'InputRadio']
      }
    },

    watch: {

      async data () {
        if (this.data && !this.add) {
          this.dataNew     = await clone(this.data)
          this.dataChanged = await this.createDataChanged(this.flatGroups(this.data))
        }
      },

      // установка типа поля VALUE при загрузке
      findTypeField () {
        if (this.findTypeField && this.findTypeField.value) {
          this.dataNewFlat[this.findVariableTypeField].type = this.findTypeField.value
        }
      }

    },

    computed: {

      // меню групп
      listMenu () {
        const data = clone(this.data)

        if (data && data.hasOwnProperty('groups')) {
          const dataGroups = clone(this.data.groups)
          const menu       = []

          dataGroups.map((item, index) => {
            menu.push({
              id:    index,
              label: item.label
            })
          })

          return menu
        }
      },

      disabled () {
        const disabled = this.dataNewFlat.find(item => item.name === 'readonly')
        if (disabled && 'value' in disabled) {
          return Number(disabled.value) || 0
        }
      },

      title () {
        if (this.add) {
          return this.$t('actions.add')
        } else {
          return this.$t('actions.edit')
        }
      },

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

      // Все поля в один уровень
      dataNewFlat () {
        if (this.dataNew) {
          return this.flatGroups(this.dataNew)
        }
      },
      // широкая / узкая панель редактирования
      editPanel_large () {
        return this.$store.getters.editPanel_large
      },

      // лоадер
      loader () {
        return this.$store.getters.editPanel_status
      },

      // если данные в форме изменились
      dataIsChanged () {
        if (this.dataChanged) {
          const data = this.dataChanged.map(item => item.changed)
          return data.includes(true)
        }
      },

      // список компонентов для ввода
      inputComponents () {
        return this.$store.getters.inputComponents
      },

      valueSelected () {
        const selected = clone(this.dataNewFlat).find(item => item.type === 'InputSelected')
        if (selected && selected.value) {
          return selected.value
        }
      },

      findVariableTypeField () {
        return this.dataNewFlat.findIndex(item => item.name === this.variableTypeField)
      },

      findTypeField () {

        return this.searchTypeInGroups(this.dataNewFlat)
        //if (this.dataNew.hasOwnProperty('groups')) {
        //
        //  return this.dataNew.find(item => item.name === 'type')
        //} else {
        //  return this.dataNew.find(item => item.name === 'type')
        //}
      },

      id () {
        const idEl = this.dataNewFlat.find(item => item.name === 'id')
        return idEl.value
      }

    },

    methods: {

      setActiveMenuItem (id) {
        this.listMenuActiveId = id
      },

      searchTypeInGroups (array) {
        if (array.hasOwnProperty('groups')) {

          // массив в один уровень
          const allFields     = array.groups
          const allFieldsFlat = allFields.map(item => item.fields)

          // поиск поля тип
          return allFieldsFlat
            .flat()
            .find(item => item.name === 'type')

        } else {
          return array.find(item => item.name === 'type')
        }
      },

      //
      flatGroups (array) {
        if (array && array.hasOwnProperty('groups')) {

          // массив в один уровень
          const allFields   = array.groups
          let allFieldsFlat = allFields.map(item => item.fields)

          if (array.hasOwnProperty('main')) {
            allFieldsFlat = allFieldsFlat.concat(array.main)
          }

          return allFieldsFlat
            .flat()

        } else {
          return array
        }
      },

      createDataChanged (arr) {

        const newArr = []

        arr.forEach(item => {
          const newItem = {
            name:    item.name,
            changed: false
          }
          newArr.push(newItem)
        })

        return newArr
      },

      variableType (type) {

        if (type === this.variableTypeField) {
          return this.variableTypeField
        } else {
          return type
        }
      },

      // изменение размеров панели редактирования
      toggleSize () {
        this.$store.commit('editPanel_size', !this.editPanel_large)
      },

      // Закрыть панель при свайпе
      swipeRight (direction) {
        if (direction === 'right') this.close()
      },

      // закрыть панель
      close () {
        if (this.dataIsChanged) {
          confirm(this.$t('messages.dataIsChanged'), this.$t('actions.ok'), this.$t('actions.no'))
            .then(() => {
              this.$emit('close')
              this.$store.commit('card_right_show', false)
            })
        } else {
          this.$emit('close')
          this.$store.commit('card_right_show', false)
        }

      },

      // смена типа поля Значение
      changeType (event) {
        this.dataNewFlat[this.findVariableTypeField].type = event
      },

      // сохранение
      save () {
        this.$emit('save', this.dataNewFlat)
      },

      // Очистка поля Value при изменении типа поля
      clearValue () {
        const value = this.dataNewFlat.find(item => item.name === 'value')
        if (value && 'value' in value) {
          value.value = ''
        }
      },

      notEditable (mode) {
        if (mode || this.disabled) {
          return 1
        } else {
          return 0
        }
      }

    }
  }

</script>
