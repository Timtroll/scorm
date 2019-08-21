<template>
  <div class="uk-form-horizontal">
    <div>
      <label v-text="label || placeholder"
             class="uk-form-label uk-text-truncate"
             v-if="label || placeholder"></label>

      <div class="uk-form-controls">
        <div class="uk-inline uk-width-1-1">

          <DatePick v-model="valueInput"
                    :format="'YYYY-MM-DD HH:mm'"
                    :displayFormat="'DD.MM.YYYY HH:mm'"
                    :selectableYearRange="5"
                    :mobileBreakpointWidth="480"
                    :inputAttributes="{class: 'uk-input uk-width-1-1', readonly: true}"
                    :pickTime="true"
                    :pickMinutes="true"
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
</template>

<script>

  import DatePick from './../datePick/DatePick'

  export default {
    components: {DatePick},

    name: 'inputDateTime',

    props: {

      value: {
        default: null
      },

      label: {
        default: null,
        type:    String
      },

      placeholder: {
        default: null,
        type:    String
      },

      editable: {
        default: true,
        type:    Boolean
      },

      mask: {
        type: String
      },

      required: {
        default: false,
        type:    Boolean
      }
    },

    data () {
      return {
        valueInput: this.value,
        valid:      true
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

      parseDate (dateString, format) {
        //return fecha.parse(dateString, format);
      },
      formatDate (dateObj, format) {
        //return fecha.format(dateObj, format);
      },

      update () {
        this.$emit('key')
        this.$emit('change', this.isChanged)
        this.$emit('value', this.valueInput)
      }
    }
  }
</script>
<style src="../../../assets/sass/components/_vueDatePick.scss" lang="scss">

</style>
