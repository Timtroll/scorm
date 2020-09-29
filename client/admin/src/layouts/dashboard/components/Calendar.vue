<template>
  <div class="pos-calendar">

    <div class="pos-calendar-header">

      <div class="pos-calendar-header-week">

        <div class="pos-calendar-header-week-item">
          <svg xmlns="http://www.w3.org/2000/svg"
               viewBox="0 0 48 48"
               width="16"
               height="16">
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
               width="16"
               height="16">
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
import {getTime}      from '@/store/methods'

export default {
  name: 'Calendar',

  components: {
    //componentName: () => import(/* webpackChunkName: "componentName" */ './componentName')
  },

  props: {
    data: {
      type:    Object,
      default: () => {}
    },
    date: {
      type:    Date,
      default: () => {
        return new Date()
      }
    }
  },

  async mounted () {
    this.$nextTick(() => {
      this.initCalendar()
      this.fullCalendar.render()
    })
  },

  beforeDestroy () {
    // выгрузка Vuex модуля
    this.fullCalendar.destroy()

  },

  data () {
    return {
      fullCalendar: null,

      //currentTime: null,

      events: [
        {
          id:            123412421,
          title:         'Чистые вещества и смеси',
          start:         new Date().setHours(8, 30, 0),
          end:           new Date().setHours(9, 15, 0),
          extendedProps: {
            discipline: 'Химия',
            theme:      'Чистые вещества и смеси',
            teacher:    {
              ava:  'https://thispersondoesnotexist.com/image',
              name: 'Рушникова Екатерина Витальевна'
            }
          }
        }, {
          id:            123412422,
          title:         'Чистые вещества и смеси',
          start:         new Date().setHours(9, 30, 0),
          end:           new Date().setHours(10, 15, 0),
          extendedProps: {
            discipline: 'Химия',
            theme:      'Чистые вещества и смеси',
            teacher:    {
              ava:  'https://thispersondoesnotexist.com/image',
              name: 'Рушникова Екатерина Витальевна'
            }
          }
        },
        {
          id:            123412423,
          title:         'Виды чисел',
          start:         new Date().setHours(10, 30, 0),
          end:           new Date().setHours(11, 15, 0),
          extendedProps: {
            discipline: 'Геометрия',
            theme:      'Параллелограмм и трапеция',
            teacher:    {
              ava:  'https://thispersondoesnotexist.com/image',
              name: 'Семенова Елена Васильевна'
            }
          }
        }

      ]
    }
  },

  computed: {},

  methods: {

    initCalendar () {

      const initialLocaleCode = 'ru'
      const initialTimeZone   = 'local'

      this.fullCalendar = new Calendar(this.$refs.calendar, {
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
            slotMinTime: '08:00:00',
            slotMaxTime: '18:00:00'
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
          startTime:  '08:00', // a start time (10am in this example)
          endTime:    '20:00' // an end time (6pm in this example)
        },

        nowIndicator: true,

        editable:     false,
        selectable:   true,
        selectMirror: true,

        eventClassNames: 'pos-calendar-event',

        eventContent: (arg) => {
          console.log(arg.event)
          const event = arg.event
          return {
            html: `
              <div class="pos-calendar-event-ava">
                <div class="pos-calendar-event-ava__image"
                  style="background-image: url(${event.extendedProps.teacher.ava})"></div>
              </div>
              <div class="pos-calendar-event-content">
                <div class="pos-calendar-event__discipline">
                  ${event.extendedProps.discipline} с ${getTime(event.start)} по ${getTime(event.end)}</div>
                <div class="pos-calendar-event__theme">${event.extendedProps.theme}</div>
                <div class="pos-calendar-event__teacher">${event.extendedProps.teacher.name}</div>
              </div>
            `
          }
        },

        eventDidMount: (info) => {
          //console.log(info.event.extendedProps)
          // {description: "Lecture", department: "BioChemistry"}
        },

        select: (arg) => {
          //console.log(arg)
          //this.calendar.unselect()
        },

        eventClick: (info) => {
          info.jsEvent.preventDefault()
          //console.log(info.event)
          info.el.classList.add('clicked')
        },

        eventMouseEnter: (info) => {
          info.el.classList.add('hover')
        },

        eventMouseLeave: (info) => {
          info.jsEvent.preventDefault()
          //console.log(info)
          info.el.classList.remove('hover')
          info.el.classList.remove('clicked')
        },

        events: this.events

      })

    },

    getTime (date) {
      getTime(date)
    }
  }
}
</script>
