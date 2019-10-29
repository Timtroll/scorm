<template>
  <li>
    <div class="uk-form-horizontal uk-overflow-hidden">
      <div>
        <label v-text="label || placeholder"
               class="uk-form-label uk-text-truncate"
               v-if="label || placeholder"/>
        <div class="uk-form-controls">
          <div class="uk-grid-small"
               uk-grid>
            <div class="uk-width-expand">
              <div class="uk-grid-collapse"
                   v-if="valuesInput"
                   uk-grid>

                <!--Values-->
                <div class="uk-width-1-1"
                     v-for="(item, index) in valuesInput"
                     :key="index">
                  <div class="uk-grid-small uk-flex-middle"
                       uk-grid>

                    <!--index-->
                    <div class="uk-width-auto uk-text-small uk-text-muted uk-visible@m"
                         style="width: 25px"
                         v-text="index"></div>

                    <!--value-->
                    <div class="uk-width-expand">
                      <div class="uk-grid-small pos-form-split"
                           uk-grid>

                        <div class="uk-inline"
                             :class="{'uk-width-1-3' : idx === 0 && doubleCell, 'uk-width-expand' : idx > 0, 'uk-width-1-1' : !doubleCell}"
                             v-for="(input, idx) in valuesInput[index]">

                          <div class="uk-form-icon uk-form-icon-flip">
                            <img src="/img/icons/icon__input_text.svg"
                                 uk-svg
                                 width="14"
                                 height="14">
                          </div>
                          <input class="uk-input uk-form-small"
                                 v-model="item[idx]"
                                 :disabled="readonly === 1"
                                 @input="update"
                                 :key="idx"
                                 type="text">
                        </div>
                      </div>
                    </div>

                    <!--Toggle cell-->
                    <div class="uk-width-auto uk-flex uk-flex-middle"
                         v-if="readonly !== 1">
                      <a class=""
                         style="transform: translateY(-3px)"
                         @click.prevent="toggleCell">
                        <img src="/img/icons/icon__minus.svg"
                             v-if="doubleCell"
                             width="14"
                             height="14"
                             uk-svg>
                        <img src="/img/icons/icon__plus.svg"
                             v-else
                             width="12"
                             height="12"
                             uk-svg>
                      </a>
                    </div>

                    <!--remove value-->
                    <div class="uk-width-auto uk-flex uk-flex-middle"
                         v-if="readonly !== 1">
                      <a class="pos-link-danger"
                         style="transform: translateY(-3px)"
                         @click.prevent="removeItem(index)">
                        <img src="/img/icons/icon__trash.svg"
                             width="12"
                             height="12"
                             uk-svg>
                      </a>
                    </div>

                  </div>
                </div>
              </div>
            </div>

            <!--Add row-->
            <div class="uk-width-auto"
                 v-if="readonly !== 1">
              <a @click.prevent="addItem">
                <img src="/img/icons/icon__plus-circle.svg"
                     width="22"
                     height="22"
                     uk-svg>
              </a>
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
    name: 'InputDoubleList',

    props: {

      value: {},

      status: { // 'loading' / 'success' / 'error'
        default: '',
        type:    String
      },

      label: {
        default: '',
        type:    String
      },

      placeholder: {
        default: '',
        type:    String
      },
      readonly:    {default: 0, type: Number},
      required:    {default: 0, type: Number}
    },

    data () {

      return {
        valuesInput: clone(this.value) || [['']],
        editValues:  false,
        doubleCell:  false
      }
    },

    mounted () {

      if (this.value[0]) {
        this.arrayLength(this.value[0])
      }
    },

    computed: {

      isChanged () {
        return JSON.stringify(this.valuesInput) !== JSON.stringify(this.value)
      }

    },

    methods: {

      arrayLength (arr) {
        if (Array.isArray(arr) && arr.length === 2) {
          this.doubleCell = true
        }
      },

      update () {
        this.$emit('change', this.isChanged)
        this.$emit('value', this.valuesInput)
      },

      removeItem (index) {

        confirm(this.$t('dialog.remove'), this.$t('actions.ok'), this.$t('actions.cancel'))
          .then(() => {
            this.valuesInput.splice(index, 1)
          })

      },

      addItem () {
        const newRow = ['', '']
        if (!this.doubleCell) {
          newRow.splice(1, 1)
        }
        this.valuesInput.push(newRow)
      },

      toggleCell () {

        const cells = this.valuesInput

        if (this.doubleCell) {

          confirm(this.$t('dialog.removeLast'), this.$t('actions.ok'), this.$t('actions.cancel'))
            .then(() => {

              cells.forEach((cell) => {
                cell.splice(1, 1)
              })
              this.doubleCell = false
            })

        } else {

          // add last input
          cells.forEach((cell) => {
            cell.push('')
          })

          this.doubleCell = true

        }
        this.valuesInput = cells
      }

    }
  }
</script>
