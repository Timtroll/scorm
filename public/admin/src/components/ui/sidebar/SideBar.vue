<template>
  <div class="pos-sidebar uk-light"
       id="sidebar">
    <div class="pos-sidebar-top uk-visible@m">
      <router-link :to="{name: 'Main'}">
        <img src="../../../../public/img/logo__bw.svg"
             class="pos-sidebar-logo"
             uk-svg>
      </router-link>
    </div>
    <div class="pos-sidebar-middle uk-light">
      <ul class="pos-sidebar--nav">
        <router-link tag="li"
                     exact-active-class="uk-active"
                     active-class="uk-active"
                     v-for="(item, index) in menu"
                     :key="index"
                     :to="item.path"
                     append
                     exact>
          <a :uk-tooltip="'title: '+ item.meta.breadcrumb + '; pos: right'">
            <img :src="item.meta.icon"
                 uk-svg
                 width="24"
                 height="24">
          </a>
        </router-link>
      </ul>
    </div>
    <div class="pos-sidebar-bottom">

      <!--user menu-->
      <SideBarUserMenu :size="30"
                       :width="1">
      </SideBarUserMenu>
    </div>
  </div>
</template>
<script>
  import SideBarUserMenu from '../sidebar/SideBarUserMenu.vue'

  export default {

    name: 'SideBar',

    components: {SideBarUserMenu},

    mounted () {

    },

    computed: {

      // side menu
      menu () {
        return this.$router.options.routes
                   .filter(item => item.sideMenuParent)[0]
          .children
          .filter(item => item.showInSideBar)
      }
    }
  }
</script>
<style scoped></style>
