<template>
  <li>
    <div class="uk-form-horizontal">
      <div>
        <label v-text="label || placeholder"
               class="uk-form-label uk-text-truncate"
               v-if="label || placeholder"/>

        <div class="uk-form-controls">
          <div class="uk-inline uk-width-1-1">
            <DatePick v-model="valueInput"
                      :format="'YYYY-MM-DD HH:mm'"
                      :displayFormat="'DD.MM.YYYY в HH:mm'"
                      :selectableYearRange="5"
                      :mobileBreakpointWidth="480"
                      :inputAttributes="{class: 'uk-input uk-width-1-1', readonly: true}"
                      :pickTime="true"
                      :disabled="readonly === 1"
                      :pickMinutes="true"
                      :parseDate="parseDate"
                      :months="$t('calendar.months')"
                      :weekdays="$t('calendar.weekdays')"
                      :setTimeCaption="$t('calendar.setTimeCaption')"
                      :prevMonthCaption="$t('calendar.prevMonthCaption')"
                      :nextMonthCaption="$t('calendar.nextMonthCaption')"
                      @input="update">
              <!--:parseDate="parseDate"-->
              <!--:formatDate="formatDate">-->
            </DatePick>
            <div class="uk-form-icon uk-form-icon-flip">
              <img src="/img/icons/icon__input_calendar.svg"
                   uk-svg
                   width="18"
                   height="18">

            </div>

          </div>
        </div>
      </div>
    </div>
  </li>
</template>

<script>
  import moment from 'moment'

  export default {
    components: {
      DatePick: () => import(/* webpackChunkName: "DatePick" */  './../datePick/DatePick')

    },

    name: 'inputDateTime',

    props: {

      value: {
        default: ''
      },

      label: {
        default: '',
        type:    String
      },

      placeholder: {
        default: '',
        type:    String
      },

      readonly: {default: 0, type: Number},
      required: {default: 0, type: Number},

      mask: {
        type: RegExp
      }

    },

    data () {
      return {
        valueInput: this.value,
        valid:      true
      }
    },

    watch: {

      valueInput () {
        if (this.mask) {
          this.valueInput = this.valueInput.replace(this.mask, '')
        }
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

      dateToSeconds (date) {
        return moment(date).unix()
      },

      parseDate () {
        return new Date(this.value * 1000)
      },

      update () {
        this.$emit('change', this.isChanged)
        this.$emit('value', this.dateToSeconds(this.valueInput))
      }
    }
  }
</script>
