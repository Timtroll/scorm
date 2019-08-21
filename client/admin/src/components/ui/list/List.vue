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
           v-text="editedData.label || labels"></div>

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
      <form class="pos-card-body-middle uk-position-relative uk-width-1-1">

        <ul class="pos-list">

          <!--editable-->
          <li v-if="!add">
            <InputBoolean
                :value="data.editable || true"
                @change="dataIsChange.editable = $event"
                @value="editedData.editable = $event"
                :placeholder="$t('list.editable')"></InputBoolean>
          </li>

          <!--name-->
          <li>
            <InputText :value="data.name || ''"
                       :required="true"
                       v-focus
                       :label="$t('list.name')"
                       @change="dataIsChange.name = $event"
                       @key="validateName"
                       @value="editedData.name = $event"
                       :placeholder="$t('list.namePlaceholder')"></InputText>
          </li>

          <!--label-->
          <li>
            <InputText :value="data.label || ''"
                       :required="true"
                       @change="dataIsChange.label = $event"
                       @value="editedData.label = $event"
                       :placeholder="$t('list.label')"></InputText>
          </li>

          <!--placeholder-->
          <li v-if="!group">
            <InputText :value="data.placeholder || ''"
                       @change="dataIsChange.placeholder = $event"
                       @value="editedData.placeholder = $event"
                       :placeholder="$t('list.placeholder')"></InputText>
          </li>

          <!--mask-->
          <li v-if="!group">
            <InputText :value="data.mask || ''"
                       @change="dataIsChange.mask = $event"
                       @value="editedData.mask = $event"
                       :placeholder="$t('list.mask')"></InputText>
          </li>

          <!--type-->
          <li v-if="!group">
            <InputSelect :value="data.type || 'InputText'"
                         :required="true"
                         :values-editable="false"
                         @change="dataIsChange.type = $event"
                         @value="changeType($event)"
                         :placeholder="$t('list.type')"
                         :values="inputComponents"></InputSelect>
          </li>

          <!-- value && values -->
          <li v-if="!group">
            <transition name="slide-right"
                        mode="out-in"
                        appear>
              <component v-bind:is="component || 'InputText'"
                         :value="data.value"

                         :values="data.selected"
                         @change="dataIsChange.value = $event"
                         @value="editedData.value = $event"
                         @values="editedData.selected = $event"
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
                @click.prevent="action"
                :disabled="!isValid">
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

  import Card from '../card/Card'

  const Loader          = () => import('../icons/Loader')
  const InputText       = () => import('../inputs/InputText')
  const InputTextarea   = () => import('../inputs/InputTextarea')
  const InputSelect     = () => import('../inputs/InputSelect')
  const InputNumber     = () => import('../inputs/InputNumber')
  const InputBoolean    = () => import('../inputs/InputBoolean')
  const InputRadio      = () => import('../inputs/InputRadio')
  const InputDoubleList = () => import('../inputs/InputDoubleList')

  export default {
    name:       'List',
    components: {Card, Loader, InputTextarea, InputText, InputSelect, InputNumber, InputBoolean, InputRadio, InputDoubleList},

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
      add:    {
        type:    Boolean,
        default: false
      },
      group:  {
        type:    Boolean,
        default: false
      },
      parent: {
        type: Number
      },
      labels: {}
    },

    beforeDestroy () {
      this.$store.commit('cms_table_row_data', null)
    },

    data () {
      return {

        component:  this.data.type,
        editedData: {
          id:          this.data.id,
          folder:      this.data.folder,
          lib_id:      +this.data.lib_id || +this.parent,
          label:       this.data.label || '',
          name:        this.data.name || '',
          type:        this.data.type,
          placeholder: this.data.placeholder,
          editable:    this.data.editable,
          mask:        this.data.mask,
          readOnly:    this.data.readOnly,
          required:    this.data.required,
          removable:   this.data.removable,
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

      isValid () {
        return (!!this.editedData.lib_id && !!this.editedData.label && !!this.editedData.name && this.dataIsChanged)
      },

      rightPanelSize () {
        return this.$store.getters.rightPanelSize
      },

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

      validateName () {
        console.log('key')
        this.editedData.name = this.editedData.name.replace(/[A-Z]/g, '')
      },

      toggleSize () {
        this.$store.commit('right_panel_size', !this.rightPanelSize)
      },

      close () {
        this.$emit('close')
        this.$store.commit('cms_table_row_show', false)
      },

      // Action on Submit
      action () {
        if (this.add && !this.group) {
          // добавить настройку
          this.set_add() // if add
        } else if (!this.add && !this.group) {
          // Сохранить настроку
          this.set_save() // if update
        } else if (this.add && this.group) {
          // Добавить группу настроек
          this.set_add_group()
        } else if (!this.add && this.group) {
          // Добавить группу настроек
          this.set_save_group()
        }
      },

      /**
       * создание настройки
       */
      set_add () {
        const data = this.editedData

        if (data.type === 'InputDoubleList') {
          data.value = JSON.stringify(data.value)
        }
        data.selected = JSON.stringify(data.selected)

        /*
        # для создания настройки
        # my $id = $self->insert_setting({
        #     "folder"      => 0,           - это запись настроек
        #     "lib_id"      => 0,           - обязательно (должно быть натуральным числом)
        #     "label"       => 'название',  - обязательно (название для отображения)
        #     "name",       => 'name'       - обязательно (системное название, латиница)
        #     "editable"    => 1,           - не обязательно, по умолчанию 1
        #     "readOnly"    => 0,           - не обязательно, по умолчанию 0
        #     "removable"   => 1,           - не обязательно, по умолчанию 1
        #     "value"       => "",            - строка или json
        #     "type"        => "InputNumber", - тип поля из конфига
        #     "placeholder" => 'это название',- название для отображения в форме
        #     "mask"        => '\d+',         - регулярное выражение
        #     "selected"    => "CKEditor",    - значение по-умолчанию для select
        #     "required"    => 1              - обязательное поле
        # });
       */
        const newData = {
          folder:      0,
          lib_id:      this.parent || data.lib_id,
          label:       data.label,
          name:        data.name,
          type:        data.type,
          placeholder: data.placeholder,
          editable:    data.editable,
          mask:        data.mask,
          readOnly:    0,
          required:    1,
          value:       data.value,
          selected:    data.selected
        }

        this.$store.dispatch('addTableRow', newData)

      },

      /**
       * сохранение настройки
       */
      set_save () {
        const data    = this.editedData
        if (data.type === 'InputDoubleList') {
          data.value = JSON.stringify(data.value)
        }
        data.selected = JSON.stringify(data.selected)

        /*
        # для сохранения настройки
        #     "id",       - обязательно (должно быть больше 0)
        #     "lib_id",   - обязательно (должно быть больше 0)
        #     "label",    - обязательно
        #     "name",     - обязательно
        #     "value",
        #     "type",
        #     "placeholder",
        #     "editable",
        #     "mask"
        #     "selected",
        # });
         */

        const newData = {
          id:          data.id,
          lib_id:      data.lib_id,
          label:       data.label,
          name:        data.name,
          type:        data.type,
          placeholder: data.placeholder,
          editable:    data.editable,
          mask:        data.mask,
          value:       data.value,
          selected:    data.selected
        }

        this.$store.dispatch('editTableRow', newData)
      },

      /**
       * создание Группы настроек
       */
      set_add_group () {
        const data = this.editedData

        /* создания настройки
        "folder"      => 1,           - это группа настроек
        "lib_id"      => 0,           - обязательно (должно быть натуральным числом)
        "label"       => 'название',  - обязательно (название для отображения)
        "name",       => 'name'       - обязательно (системное название, латиница)
        "editable"    => 1,           - не обязательно, по умолчанию 1
        "readOnly"    => 0,           - не обязательно, по умолчанию 0
        "removable"   => 1,           - не обязательно, по умолчанию 1
       */
        const newData = {
          folder:    1,
          lib_id:    data.lib_id,
          label:     data.label,
          name:      data.name,
          readOnly:  0,
          removable: 1,
          required:  1
        }

        this.$store.dispatch('addGroup', newData)

      },
      /**
       * создание Группы настроек
       */
      set_save_group () {
        const data = this.editedData

        /* редактирования настройки
        "folder"      => 1,           - это группа настроек
        "lib_id"      => 0,           - обязательно (должно быть натуральным числом)
        "label"       => 'название',  - обязательно (название для отображения)
        "name",       => 'name'       - обязательно (системное название, латиница)
        "editable"    => 1,           - не обязательно, по умолчанию 1
        "readOnly"    => 0,           - не обязательно, по умолчанию 0
        "removable"   => 1,           - не обязательно, по умолчанию 1
       */
        const newData = {
          folder:    1,
          id:        data.id,
          lib_id:    data.lib_id,
          label:     data.label,
          name:      data.name,
          readOnly:  0,
          removable: 1,
          required:  1
        }

        this.$store.dispatch('addGroup', newData)

      },

      changeType (event) {
        this.component       = event
        this.editedData.type = event
      }

    }
  }
</script>
