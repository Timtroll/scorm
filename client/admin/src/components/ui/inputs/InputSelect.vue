<template>
  <div class="uk-form-horizontal uk-overflow-hidden">
    <div>
      <label v-text="label || placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="label || placeholder"></label>

      <div class="uk-form-controls">
        <div class="uk-grid-small"
             uk-grid>
          <div class="uk-width-expand"
               uk-form-custom="target: > * > span:first-child">

            <select v-model="valueInput"
                    v-if="isObject"
                    :disabled="!editable || editValues"
                    @change="update">
              <option v-for="item in notEmptyEditValues"
                      :value="item.value">{{item.label}}
              </option>
            </select>
            <select v-model="valueInput"
                    v-else
                    :disabled="!editable || editValues"
                    @change="update">
              <option v-for="item in valuesInput">{{item}}</option>
            </select>

            <button class="uk-button uk-height-1-1 uk-button-default uk-width-1-1 uk-flex uk-flex-between uk-flex-middle"
                    :class="validate"
                    type="button"
                    tabindex="-1">
              <span></span>
              <img src="/img/icons/icon_arrow__down.svg"
                   uk-svg
                   width="14"
                   height="14">
            </button>
          </div>

          <!--edit Options toggle-->
          <div class="uk-width-auto"
               v-if="valuesEditable">
            <button type="button"
                    class="uk-button"
                    :class="{'uk-button-primary' : !editValues, 'uk-button-success' : editValues}"
                    @click.prevent="toggleEditOptions">
              <img src="/img/icons/icon__edit.svg"
                   width="16"
                   height="16"
                   uk-svg
                   v-if="!editValues">
              <img src="/img/icons/icon__save.svg"
                   width="16"
                   height="16"
                   uk-svg
                   v-else>
            </button>
          </div>
        </div>

        <!--editValues-->
        <transition name="slide-bottom">
          <div class="pos-placeholder"
               v-if="editValues && valuesEditable">
            <div class="uk-grid-small uk-flex-middle"
                 uk-grid>

              <!--Title-->
              <div class="uk-width-expand uk-text-bold"
                   v-text="$t('actions.edit_fields')"></div>

              <!--Add value-->
              <div class="uk-width-auto">
                <button type="button"
                        @click="addItem"
                        class="uk-button uk-button-link">
                  <img src="/img/icons/icon__plus-circle.svg"
                       width="22"
                       height="22"
                       uk-svg>
                </button>
              </div>

              <!--Values-->
              <div class="uk-width-1-1"
                   v-for="(item, index) in valuesInput"
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
                           v-model="valuesInput[index]"
                           :key="index"
                           v-focus
                           @keyup.enter="addItem"
                           type="text">
                  </div>

                  <!--remove value-->
                  <div class="uk-width-auto">
                    <a class="uk-button uk-button-link pos-link-danger"
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
        </transition>
      </div>
    </div>

  </div>
</template>

<script>

  import UIkit from 'uikit/dist/js/uikit.min'

  export default {
    name: 'InputSelect',

    props: {

      value:          {
        default: ''
      },
      values:         {
        type:    Array,
        default: ['']
      },
      label:          {
        default: null,
        type:    String
      },
      status:         { // 'loading' / 'success' / 'error'
        default: null,
        type:    String
      },
      placeholder:    {
        default: null,
        type:    String
      },
      valuesEditable: {
        default: true,
        type:    Boolean
      },
      editable:       {
        default: true,
        type:    Boolean
      },
      required:       {
        default: false,
        type:    Boolean
      }
    },

    data () {

      return {
        valueInput:  this.value,
        valuesInput: JSON.parse(JSON.stringify(this.values)) || [''],
        editValues:  false
      }
    },

    watch: {

      valuesInput () {

        // Проверка на наличие Value in Values
        const value         = this.valueInput,
              values        = this.valuesInput,
              valueInValues = values.includes(value)

        if (!valueInValues) {
          this.valueInput = ''
        }
        this.update()
      }
    },

    computed: {

      isObject () {
        return (typeof this.valuesInput[0] === 'object' && !Array.isArray(this.valuesInput[0]) && this.valuesInput[0] !== null)
      },

      isChanged () {
        return this.valueInput !== this.value || JSON.stringify(this.valuesInput) !== JSON.stringify(this.values)
      },

      notEmptyEditValues () {
        const des       = this.valuesInput || []
        const defFilter = [...new Set(des)]
        return defFilter.filter(Boolean).sort()
      }

    },

    methods: {

      toggleEditOptions () {
        this.editValues = !this.editValues
        if (!this.editValues) {
          this.valuesInput = this.notEmptyEditValues
        }
      },

      update () {
        this.$emit('change', this.isChanged)
        this.$emit('value', this.valueInput)
        this.$emit('values', this.notEmptyEditValues)
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

        UIkit.modal.confirm(this.$t('dialog.remove'), {
          labels: {
            ok:     this.$t('actions.ok'),
            cancel: this.$t('actions.cancel')
          }
        }).then(() => {
          this.valuesInput.splice(index, 1)
        })

      },

      addItem () {
        if (this.valuesInput.indexOf('') === -1) {
          this.valuesInput.push('')
        }
      }
    }
  }
</script>
