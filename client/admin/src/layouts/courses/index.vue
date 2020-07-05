<template>

  <Finder :data="list"/>
</template>

<script>
import courses from '@/store/modules/courses'
import list from '@/assets/json/proto/finder/finder-folders.json'

export default {
  name: 'Courses',

  components: {
    Finder: () => import(/* webpackChunkName: "Finder" */ '../../components/ui/finder/Finder')
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

  data () {
    return {
      list: null
    }
  },

  async mounted () {
    await this.$store.registerModule('courses', courses)
    await this.getFinderLevel()
  },

  beforeDestroy () {
    // выгрузка Vuex модуля settings
    this.$store.unregisterModule('courses')
  },

  computed: {

    pageTitle () {
      return this.$route.meta.breadcrumb
    }

  },

  methods: {

    async getFinderLevel (id) {

      try {

        this.list = list
      }
      catch (e) {
        console.log(e)
      }
    }
  }
}
</script>

<style lang="sass">
@import "sass/index"
</style>
