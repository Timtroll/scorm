<template>
  <div class="uk-form-horizontal uk-overflow-hidden">
    <div>
      <label v-text="placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="placeholder"></label>

      <div class="uk-form-controls">
        <div class="uk-grid-small"
             uk-grid>
          <div class="uk-width-expand"
               uk-form-custom="target: > * > span:first-child">
            <select v-model.number="valueInput"
                    :disabled="!editable || editValues"
                    @change="update">
              <option value="item"
                      v-for="item in valuesInput">{{item}}
              </option>

            </select>
            <button class="uk-button uk-height-1-1 uk-button-default uk-width-1-1 uk-flex uk-flex-between uk-flex-middle"
                    :class="statusClass"
                    type="button"
                    tabindex="-1">
              <span></span>
              <img src="/img/icons/icon_arrow__down.svg"
                   uk-svg
                   width="14"
                   height="14">
            </button>
          </div>
          <div class="uk-width-auto">
            <button type="button"
                    class="uk-button"
                    :class="{'uk-button-primary' : !editValues, 'uk-button-danger' : editValues}"
                    @click.prevent="editValues = !editValues">
              <img src="/img/icons/icon__edit.svg"
                   width="16"
                   height="16"
                   uk-svg>
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
                           width="18"
                           height="18">
                    </div>
                    <input class="uk-input uk-form-small"
                           v-model="valuesInput[index]"
                           :key="index"
                           type="text">
                  </div>

                  <!--remove value-->
                  <div class="uk-width-auto">
                    <a class="uk-button uk-button-small uk-button-danger"
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
  export default {
    name: 'InputSelect',

    props: {

      value:       {
        default: null
      },
      values:      {
        type: Array
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
        default: false,
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

    methods: {

      statusClass () {
        switch (this.stats) {
          case 'loading':
            'loading'
            break
          case 'success':
            'success'
            break
          case 'error':
            'error'
            break

        }
      },

      update () {
        this.$emit('update', this.value)
      },

      removeItem (index) {
        this.valuesInput.splice(index, 1)
      },

      addItem () {
        this.valuesInput.push('')
      }
    }
  }
</script>
