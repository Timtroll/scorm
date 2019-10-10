<template>
  <div class="uk-height-1-1 uk-flex uk-flex-center uk-flex-middle uk-text-center">
    <div>
      <h1 class="uk-h1 uk-text-muted"
          v-text="pageTitle"></h1>

    </div>
  </div>
</template>

<script>

  export default {

    name: 'DashBoard',

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
