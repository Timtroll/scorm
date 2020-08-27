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

        <Calendar :data="calendar"/>

        <div class="pos-dashboard-tasks"></div>
      </div>

    </template>

  </Card>
</template>

<script>

import dashboard from './store'
import Calendar  from '@/layouts/dashboard/components/Calendar'

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
      //this.startRTC()
    })

    // показать кнопку меню в navBar
    //await this.getUsers()
  },

  async created () {
    // Регистрация Vuex модуля settings
    await this.$store.registerModule('dashboard', dashboard)
  },

  beforeDestroy () {
    // выгрузка Vuex модуля
    this.$store.unregisterModule('dashboard')
  },

  data () {
    return {
      loader:   'success',
      calendar: {
        data:    null,
        options: null
      }
    }
  },

  computed: {

    pageTitle () {
      return this.$route.meta.breadcrumb
    }

  }
}
</script>
<style lang="sass">
@import "./sass"
</style>
