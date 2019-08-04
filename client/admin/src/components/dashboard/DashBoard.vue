<template>
  <div class="uk-height-1-1 uk-flex uk-flex-center uk-flex-middle uk-text-center">
    <div>
      <h1 class="uk-heading-xlarge uk-text-muted"
          v-text="pageTitle"></h1>
      <Loader :width="50"
              :height="50"></Loader>
    </div>
  </div>
</template>

<script>
  import Loader from '../ui/icons/Loader'

  export default {

    name:       'DashBoard',
    components: {Loader},

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
