<template>
  <div class="pos-body">
    <div class="pos-main">
      <div class="pos-container">
        <!--main-container-->
        <div class="pos-content uk-flex uk-flex-middle uk-flex-center uk-text-center">
          <div>
            <p class="uk-heading-xlarge"
               v-text="$t('pageNotFound.title')"></p>
            <p class="uk-h4 uk-text-lowercase uk-margin-remove uk-text-muted"
               v-text="$t('pageNotFound.content')"></p>
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

  export default {
    name: 'PageNotFound',

    components: {
      NavBar:  () => import(/* webpackChunkName: "nav-bar" */  '../components/ui/navbar/NavBar'),
      SideBar: () => import(/* webpackChunkName: "side-bar" */  '../components/ui/sidebar/SideBar')
    },

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

