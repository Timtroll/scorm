<template>
  <li>
    <div class="uk-form-horizontal">
      <div>
        <label v-text="label"
               class="uk-form-label uk-text-truncate"
               v-if="label"/>

        <div class="uk-form-controls">
          <div class="uk-input cursor-pointer"
               @click.prevent="toggleEditOptions">
            <div class="uk-grid-small uk-flex-middle"
                 uk-grid>
              <div class="uk-width-expand uk-flex-middle uk-flex"
                   v-if="notEmptyEditValues.length > 0">
              <span class="uk-margin-small-right"
                    v-text="$t('actions.total')"/>
                <span class="uk-badge uk-label-danger"
                      v-text="notEmptyEditValues.length"/>
              </div>
              <div class="uk-width-expand"
                   v-else
                   v-text="$t('actions.empty')"/>

              <!--edit Options toggle-->
              <div class="uk-width-auto"
                   v-if="valuesEditable && readonly === 0">

                <a class="uk-icon-link"
                   :class="{'uk-text-primary' : !editValues, 'uk-text-danger' : editValues}">

                  <img src="/img/icons/icon__edit.svg"
                       width="20"
                       height="20"
                       uk-svg
                       v-if="!editValues">
                  <img src="/img/icons/icon__save.svg"
                       width="20"
                       height="20"
                       uk-svg
                       v-else>
                </a>
              </div>
            </div>
          </div>

          <!--editValues-->
          <div class="pos-placeholder"
               v-if="editValues && valuesEditable && readonly !== 1">
            <div class="uk-grid-collapse uk-flex-middle"
                 uk-grid>

              <!--Title-->
              <div class="uk-width-expand uk-text-bold"
                   v-text="$t('actions.edit_fields')"></div>

              <!--Add value-->
              <div class="uk-width-auto">
                <a @click.prevent="addItem"
                   class="">
                  <img src="/img/icons/icon__plus-circle.svg"
                       width="22"
                       height="22"
                       uk-svg>
                </a>
              </div>

              <!--Values-->
              <div class="uk-width-1-1 uk-margin-top">
                <div v-for="(item, index) in valueInput"
                     :key="index">

                  <div class="uk-grid-small uk-flex-middle"
                       uk-grid>

                    <!--index-->
                    <div class="uk-width-auto"
                         style="width: 30px"
                         v-text="index"></div>

                    <!--value-->
                    <div class="uk-inline uk-width-expand">
                      <div class="uk-form-icon uk-form-icon-flip">
                        <img src="/img/icons/icon__input_text.svg"
                             uk-svg
                             width="14"
                             height="14">
                      </div>
                      <input class="uk-input uk-form-small"
                             v-model="valueInput[index]"
                             :key="index"
                             v-focus
                             @input="update"
                             @keyup.enter="addItem"
                             type="text">
                    </div>

                    <!--remove value-->
                    <div class="uk-width-auto">
                      <a class="pos-link-danger"
                         style="transform: translateY(-3px)"
                         @click.prevent="removeItem(index)">
                        <img src="/img/icons/icon__trash.svg"
                             width="14"
                             height="14"
                             uk-svg>
                      </a>
                    </div>

                  </div>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>

    </div>
  </li>
</template>

<script>

  import {clone, confirm} from '../../../store/methods'

  export default {
    name: 'InputSelected',

    props: {

      value:    {},
      selected: {
        default: ['']
      },

      label: {
        default: '',
        type:    String
      },

      status: { // 'loading' / 'success' / 'error'
        default: '',
        type:    String
      },

      placeholder: {
        default: '',
        type:    String
      },

      showSelected: {
        default: false,
        type:    Boolean
      },

      valuesEditable: {
        default: true,
        type:    Boolean
      },
      readonly:       {default: 0, type: Number},
      required:       {default: 0, type: Number}
    },

    data () {

      return {
        valueInput: clone(this.value),
        editValues: false
      }
    },

    computed: {

      isObject () {
        return (typeof this.valueInput[0] === 'object' && !Array.isArray(this.valueInput[0]) && this.valueInput[0] !== null)
      },

      isChanged () {
        return JSON.stringify(this.notEmptyEditValues) !== JSON.stringify(this.values)
      },

      notEmptyEditValues () {
        const des       = this.valueInput || []
        const defFilter = [...new Set(des)]
        return defFilter.filter(Boolean).sort()
      }

    },

    methods: {

      toggleEditOptions () {
        this.editValues = !this.editValues
        if (!this.editValues) {
          this.valueInput = this.notEmptyEditValues
        }
      },

      update () {
        this.$emit('change', this.isChanged)
        this.$emit('value', this.notEmptyEditValues)
      },

      validate () {

        let validClass = null
        if (this.required) {
          if (!this.valueInput || this.valueInput.length < 3) {
            validClass = 'uk-form-danger'
            this.valid = false
            this.$emit('valid', this.valid)
          } else {
            validClass = 'uk-form-success'
            this.valid = true
            this.$emit('valid', this.valid)
          }
        }
        return validClass
      },

      removeItem (index) {

        confirm(this.$t('dialog.remove'), this.$t('actions.ok'), this.$t('actions.cancel'))
          .then(() => {
            this.valueInput.splice(index, 1)
          })

      },

      addItem () {
        if (this.valueInput.indexOf('') === -1) {
          this.valueInput.push('')
        }
      }
    }
  }
</script>
