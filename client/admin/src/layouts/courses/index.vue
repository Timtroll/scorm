<template>

  <Finder/>
</template>

<script>

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
    return {}
  },

  computed: {

    pageTitle () {
      return this.$route.meta.breadcrumb
    }

  }
}
</script>

<style lang="sass">
@import "sass/index"
</style>
