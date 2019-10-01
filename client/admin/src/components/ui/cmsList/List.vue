<template>
  <div class="pos-card">

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

          <li v-for="(item, index) in dataNew"
              :key="index">
            <component v-bind:is="item.type"
                       :value="item.value"
                       :name="item.name"
                       :selected="item.selected"
                       :readonly="item.readonly"
                       :add="item.add"
                       :required="item.required"
                       :mask="item.mask"
                       :label="item.label"
                       :placeholder="item.placeholder"
                       @change="dataChanged[index].changed = $event"
                       @changeType="changeType($event)">
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
        <button class="uk-button-success uk-button uk-button-small"
                @click.prevent="save"
                :disabled="!dataIsChanged">
          <img src="/img/icons/icon__save.svg"
               uk-svg
               width="14"
               height="14">

          <span class="uk-margin-small-left"
                v-text="$t('actions.add')"
                v-if="add"></span>
          <span class="uk-margin-small-left"
                v-text="$t('actions.save')"
                v-else></span>
        </button>
      </div>

    </div>
  </div>

</template>

<script>

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
      InputCode:       () => import('../inputs/InputCode'),
      InputType:       () => import('../inputs/InputType')
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

    beforeDestroy () {
      this.$store.commit('editPanel_data', null)
    },

    data () {
      return {
        dataNew:     [],
        dataChanged: []
      }
    },

    watch: {

      data () {

        if (this.data) {
          this.dataNew     = JSON.parse(JSON.stringify(this.data))
          this.dataChanged = this.createDataChanged(this.data)
        }

      },

      // установка типа поля VALUE при загрузке
      findTypeField () {
        if (this.findTypeField && this.findTypeField.value) {
          this.dataNew[this.findVariableTypeField].type = this.findTypeField.value
        }
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

      // если данные в форме изменились
      dataIsChanged () {
        if (this.dataChanged) {
          const data = this.dataChanged.map(item => item.changed)
          console.log(data)
          return data.includes(true)
        }
      },

      // список компонентов для ввода
      inputComponents () {
        return this.$store.getters.inputComponents
      },

      findVariableTypeField () {
        return this.dataNew.findIndex(item => item.name === this.variableTypeField)
      },

      findTypeField () {
        return this.dataNew.find(item => item.name === 'type')
      },

      id () {
        const idEl = this.dataNew.find(item => item.name === 'id')
        return idEl.value
      }



      ////
      //parentId () {
      //  return this.rowData.parent || this.parent || 0
      //}
    },

    methods: {

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

      toggleSize () {
        this.$store.commit('editPanel_size', !this.editPanel_large)
      },

      close () {
        this.$emit('close')
        this.$store.commit('card_right_show', false)
      },

      changeType (event) {
        this.dataNew[this.findVariableTypeField].type = event
      },

      save () {
        this.$emit('save', this.dataNew)
      }

    }
  }

</script>
