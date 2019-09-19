<template>
  <div class="pos-body">
    <div class="pos-main">
      <div class="pos-container">
        <!--main-container-->
        <div class="pos-content uk-flex uk-flex-middle uk-flex-center uk-text-center">
          <div>
            <p class="uk-heading-2xlarge"
               v-text="$t('err404.title')"></p>
            <p class="uk-h4 uk-text-lowercase uk-margin-remove uk-text-muted"
               v-text="$t('err404.settings')"></p>
          </div>
        </div>

        <!--NavBar-->
        <NavBar></NavBar>
      </div>

      <!--sidebar-->
      <SideBar></SideBar>
    </div>
  </div>
</template>

<script>

  import SideBar from '../components/ui/sidebar/SideBar'
  import NavBar from '../components/ui/navbar/NavBar'

  export default {
    name: 'PageNotFound',

    components: {NavBar, SideBar},

    metaInfo () {
      return {
        title:         this.$t('auth.title'),
        titleTemplate: '%s - Scorm',
        htmlAttrs:     {
          lang: this.$t('app.lang')
        }
      }
    },

    data () {
      return {}
    }
  }
</script>

