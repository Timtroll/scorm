<template>
  <Finder :data="list"/>
</template>

<script>
import courses from '@/store/modules/courses'
import list    from '@/assets/json/proto/finder/finder-folders.json'

export default {
  name: 'Courses',

  components: {
    Finder: () => import(/* webpackChunkName: "Finder" */ '@/components/ui/finder/Finder')
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
      rootList: null,
      list:     null
    }
  },

  async mounted () {
    await this.$store.registerModule('courses', courses)
    await this.getFinderRoot()
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

    async getFinderRoot () {

      try {
        const response = await this.$store.dispatch('courses/getRoot', {route: 'discipline/'})
        //console.log(await response)
        //this.rootList = await response
      }
      catch (e) {
        console.log(e)
      }
    },

    async getFinderLevel (route, id) {

      try {
        const response = await this.$store.dispatch('courses/getLevel', {
          route: route,
          id:    id
        })
        console.log(await response)

        //this.list = list
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
