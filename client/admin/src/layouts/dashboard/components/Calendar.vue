<template>
  <div class="pos-calendar">

    <div class="pos-calendar-header">

      <div class="pos-calendar-header-week">
        <div class="pos-calendar-header-week-item">
          <svg xmlns="http://www.w3.org/2000/svg"
               viewBox="0 0 48 48"
               width="18"
               height="18">
            <polyline points="33 6 15 24 33 42"
                      fill="none"
                      stroke="currentColor"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="8"/>
          </svg>
        </div>
        <div class="pos-calendar-header-week-item">Пн</div>
        <div class="pos-calendar-header-week-item">Вт</div>
        <div class="pos-calendar-header-week-item">Ср</div>
        <div class="pos-calendar-header-week-item">Чт</div>
        <div class="pos-calendar-header-week-item active">Пт</div>
        <div class="pos-calendar-header-week-item">Сб</div>
        <div class="pos-calendar-header-week-item">Вс</div>
        <div class="pos-calendar-header-week-item">
          <svg xmlns="http://www.w3.org/2000/svg"
               viewBox="0 0 48 48"
               width="18"
               height="18">
            <polyline points="15 42 33 24 15 6"
                      fill="none"
                      stroke="currentColor"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="8"/>
          </svg>
        </div>
      </div>

    </div>

    <div ref="calendar"
         class="pos-calendar-body"></div>

  </div>
</template>

<script>

import {Calendar}     from '@fullcalendar/core'
import timeGridPlugin from '@fullcalendar/timegrid'

export default {
  name: 'Calendar',

  components: {
    //componentName: () => import(/* webpackChunkName: "componentName" */ './componentName')
  },

  props: {
    data: {
      type:    Object,
      default: () => {}
    }
  },

  async mounted () {
    this.$nextTick(() => {

      const initialLocaleCode = 'ru'
      const initialTimeZone   = 'local'

      this.calendar = new Calendar(this.$refs.calendar, {
        plugins:       [timeGridPlugin],
        locale:        initialLocaleCode,
        timeZone:      initialTimeZone,
        themeSystem:   'standard',
        firstDay:      1,
        allDaySlot:    false,
        //headerToolbar: {
        //  left:   'prev,today,next',
        //  center: null,
        //  right:  null
        //},
        headerToolbar: false,

        initialView: 'timeGridDay',
        initialDate: new Date(),

        views:               {
          timeGrid: {
            slotMinTime: '09:00:00',
            slotMaxTime: '16:00:00'
          }
        },
        slotDuration:        '00:15:00',
        slotLabelClassNames: 'pos-calendar-time',
        slotLabelFormat:     {
          hour:           'numeric',
          minute:         '2-digit',
          omitZeroMinute: false
        },

        businessHours: {
          daysOfWeek: [1, 2, 3, 4, 5], // Monday - Thursday
          startTime:  '09:00', // a start time (10am in this example)
          endTime:    '16:00' // an end time (6pm in this example)
        },

        nowIndicator: true,

        editable:     false,
        selectable:   true,
        selectMirror: true,

        select: (arg) => {
          console.log(arg)

          //this.calendar.unselect()
        },

        events: [
          {
            title: 'Conference',
            start: new Date().setHours('12', '00', '00')
            //end: '2020-06-13'
          }
        ]

      })
      this.calendar.render()
      //this.calendar.scrollToTime(new Date())
      console.log(this.calendar)
    })
  },

  beforeDestroy () {
    // выгрузка Vuex модуля
    this.calendar.destroy()
  },

  data () {
    return {
      calendar: null
    }
  }
}
</script>

<style lang="sass">
</style>
