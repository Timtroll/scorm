<template>
  <div class="uk-form-horizontal uk-overflow-hidden">
    <div>
      <label v-text="label || placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="label || placeholder"></label>

      <div class="uk-form-controls">
        <div class="uk-grid-small"
             uk-grid>
          <div class="uk-width-expand">

            <div v-for="(item, index) in valuesInput"
                 class="uk-grid-small uk-flex-middle"
                 uk-grid>

              <!--index-->
              <div class="uk-width-auto uk-text-small uk-text-muted uk-visible@m"
                   style="width: 25px"
                   v-text="index"></div>

              <!--value-->
              <div class="uk-width-expand">

                <div class="uk-inline uk-width-1-1">
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

          <!--Add row-->
          <div class="uk-width-auto">
            <button type="button"
                    class="uk-button uk-button-primary"
                    @click.prevent="addItem">
              <img src="/img/icons/icon__plus.svg"
                   width="16"
                   height="16"
                   uk-svg>
            </button>
          </div>
        </div>

      </div>
    </div>

  </div>
</template>

<script>

  import UIkit from 'uikit/dist/js/uikit.min'

  export default {
    name: 'InputList',

    props: {

      value:       {},
      status:      { // 'loading' / 'success' / 'error'
        default: '',
        type:    String
      },
      placeholder: {
        default: '',
        type:    String
      },
      label: {
        default: '',
        type:    String
      },
      editable:    {default: 1}
    },

    data () {

      return {
        valuesInput: this.value
      }
    },

    methods: {


      update () {
        this.$emit('value', this.value)
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
