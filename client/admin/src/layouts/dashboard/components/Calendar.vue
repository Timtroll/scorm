<template>
  <div ref="calendar"
       class="pos-calendar"></div>
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
        headerToolbar: {
          left:   'prev,today,next',
          center: null,
          right:  null
        },

        initialView: 'timeGridDay',
        initialDate: new Date(),

        views:               {
          timeGrid: {
            slotMinTime: '09:00:00',
            slotMaxTime: '16:00:00'
          }
        },
        slotDuration:        '00:05:00',
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
