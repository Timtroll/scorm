<template>
  <div class="uk-form-horizontal uk-overflow-hidden">
    <div>
      <label v-text="placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="placeholder"></label>

      <div class="uk-form-controls">

        <!--Value-->
        <div class="uk-grid-small"
             uk-grid>

          <div class="uk-width-expand">
            <label class="uk-width-1-1 uk-form-controls-text uk-flex uk-flex-middle uk-grid-collapse"
                   uk-grid=""
                   v-for="(radio, index) in values">
              <input
                  class="pos-checkbox-switch"
                  :disabled="!editable || editValues"
                  :value="valuesInput[index]"
                  v-model="valueInput"
                  :checked="valueInput"
                  @change="update"
                  type="radio">
              <div class="uk-width-expand">
              <span class="uk-text-truncate uk-margin-small-left"
                    v-text="radio"></span>
              </div>
            </label>

          </div>

          <!--toggle edit Values-->
          <div class="uk-width-auto">
            <button type="button"
                    class="uk-button"
                    :class="{'uk-button-primary' : !editValues, 'uk-button-danger' : editValues}"
                    @click.prevent="editValues = !editValues">
              <img src="/img/icons/icon__edit.svg"
                   width="16"
                   height="16"
                   uk-svg
                   v-if="!editValues">
              <img src="/img/icons/icon__close.svg"
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
               v-if="editValues">
            <div class="uk-grid-small uk-flex-middle"
                 uk-grid>

              <!--Title-->
              <div class="uk-width-expand uk-text-bold"
                   v-text="$t('actions.edit_fields')"></div>

              <!--Add value-->
              <div class="uk-width-auto">
                <button type="button"
                        @click="addItem"
                        class="uk-button uk-button-small uk-button-primary">
                  <img src="/img/icons/icon__plus.svg"
                       width="14"
                       height="14"
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
    name: 'InputRadio',

    props: {
      value:       {
        default: null
      },
      values:      {
        default: null
      },
      status:      { // 'loading' / 'success' / 'error'
        default: null,
        type:    String
      },
      placeholder: {
        default: null,
        type:    String
      },
      editable:    {
        default: true,
        type:    Boolean
      }
    },

    data () {
      return {
        valueInput:  this.value,
        valuesInput: this.values,
        editValues:  false
      }
    },

    computed: {

      isChanged () {
        return this.valueInput !== this.value
      },

      validate () {

        let validClass = null
        if (this.required) {
          if (!this.valueInput && this.valueInput.length < 1) {
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
      }
    },

    methods: {

      update () {
        this.$emit('change', this.isChanged)
        this.$emit('value', this.valueInput)
        this.$emit('values', this.valuesInput)
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
        this.valuesInput.push('')
      }
    }
  }
</script>
