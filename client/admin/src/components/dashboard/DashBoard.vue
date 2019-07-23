<template>
  <div class="uk-height-1-1 uk-flex uk-flex-center uk-flex-middle uk-text-center">
    <h1 class="uk-heading-xlarge uk-text-muted" v-text="pageTitle"></h1>
  </div>
</template>

<script>
  export default {

    name: 'DashBoard',

    metaInfo: {
      title:         'Рабочий стол',
      titleTemplate: '%s - Scorm',
      htmlAttrs:     {
        lang: 'ru'
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
