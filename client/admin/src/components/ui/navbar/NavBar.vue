<template>
  <div class="pos-navbar">
    <div class="pos-navbar-left"
         v-if="leftToggle.visibility">
      <div class="pos-navbar-item">
        <a class="pos-card-header-item link"
           :class="{'uk-text-danger' : leftToggle.state}"
           @click.prevent="leftToggleAction">
          <img :src="'/img/icons/' + leftToggle.icon"
               uk-svg
               width="20"
               height="20">
        </a>
      </div>
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

    name: 'NavBar',

    components: {NavBarUserMenu},

    data () {
      return {
        userMenu: false
      }
    },

    computed: {

      leftToggle () {
        return this.$store.getters.navbarLeftAction
      },

      leftToggleState () {
        return this.$store.getters.navbarLeftActionState
      },

      pageTitle () {
        return this.$route.meta.breadcrumb
      }

    },

    methods: {
      leftToggleAction () {
        this.$store.commit('setNavbarLeftActionState', !this.leftToggleState)
      }
    }
  }
</script>
