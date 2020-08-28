<template>
  <Card :header="false"
        :footer="false"
        :body-left="false"
        :body-left-toggle-show="false"
        :body-right="false"
        :loader="loader"
        :body-padding="false">

    <!-- // Body // -->
    <template #body>

      <div class="pos-dashboard">

        <Calendar :data="calendar" :time="currentTime" :date="currentDate"/>

        <div class="pos-dashboard-tasks"></div>
      </div>

    </template>

  </Card>
</template>

<script>

import dashboard from './store'
import Calendar  from '@/layouts/dashboard/components/Calendar'

let time

export default {

  name: 'DashBoard',

  components: {
    Calendar,
    IconBug: () => import(/* webpackChunkName: "IconBug" */ '@/components/ui/icons/IconBug'),
    Card:    () => import(/* webpackChunkName: "Card" */ '@/components/ui/card/Card'),
    Loader:  () => import(/* webpackChunkName: "Loader" */ '@/components/ui/icons/Loader')
  },

  metaInfo () {
    return {
      title:         this.$route.meta.breadcrumb,
      titleTemplate: '%s - Scorm',
      htmlAttrs:     {
        lang: this.$t('app.lang')
      }
    }
  },

  async mounted () {
    this.$store.commit('navBarLeftActionShow', false)

    this.$nextTick(() => {
      this.getCurrentDate()
    })

    // показать кнопку меню в navBar
    //await this.getUsers()
  },

  async created () {
    // Регистрация Vuex модуля settings
    await this.$store.registerModule('dashboard', dashboard)
  },

  beforeDestroy () {
    clearInterval(time)
    // выгрузка Vuex модуля
    this.$store.unregisterModule('dashboard')
  },

  data () {
    return {
      loader:   'success',
      calendar: {
        data:    null,
        options: null
      },

      currentDate: null,
      currentTime: null
    }
  },

  watch: {

    currentDate () {
      const date       = new Date(this.currentDate)
      this.currentTime = `${this.setZero(date.getHours())}:${this.setZero(date.getMinutes())}`
    }
  },

  computed: {

    pageTitle () {
      return this.$route.meta.breadcrumb
    }

  },

  methods: {

    setZero (number) {
      return (number < 10) ? `0${number}` : number
    },

    getCurrentDate () {
      time = setInterval(() => {
        this.currentDate = new Date()
        //.toISOString()
        //.toLocaleString('ru')
      }, 1000)
    }
  }
}
</script>
<style lang="sass">
@import "./sass"
</style>
