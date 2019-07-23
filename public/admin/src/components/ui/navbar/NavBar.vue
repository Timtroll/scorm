<template>
  <div class="pos-navbar">
    <div class="pos-navbar-left">
      <div class="pos-navbar-item">L</div>
    </div>
    <div class="pos-navbar-middle">
      <div class="pos-navbar__title"
           v-text="pageTitle"></div>
      <div class="pos-navbar__meta">
        <ul class="uk-breadcrumb">
          <li><a href="#">Item</a></li>
          <li><a href="#">Item</a></li>
        </ul>
      </div>
    </div>
    <div class="pos-navbar-right">

      <a class="pos-navbar-item">
        <img src="../../../../public/img/icons/user_profile.svg"
             uk-svg
             width="24"
             height="24">
      </a>
      <NavBarUserMenu></NavBarUserMenu>
    </div>
  </div>
</template>

<script>

  import NavBarUserMenu from './NavBarUserMenu'

  export default {

    name:       'NavBar',
    components: {NavBarUserMenu},
    data () {
      return {
        userMenu: false
      }
    },

    computed: {

      pageTitle () {
        return this.$route.meta.breadcrumb
      }

    }
  }
</script>
