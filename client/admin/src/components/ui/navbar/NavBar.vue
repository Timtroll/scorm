<template>
  <div class="pos-navbar">
    <div class="pos-navbar-left"
         v-if="leftToggle.visibility">
      <div class="pos-navbar-item">
        <a class="pos-card-header-item link"
           :class="{'uk-text-danger' : leftToggleState}"
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
           v-html="pageTitle"></div>

      <!--<div class="pos-navbar__meta">-->
      <!--  <ul class="uk-breadcrumb">-->
      <!--    <li><a href="#">Item</a></li>-->
      <!--    <li><a href="#">Item</a></li>-->
      <!--  </ul>-->
      <!--</div>-->
    </div>

    <!--navbar right-->
    <div class="pos-navbar-right">

      <a class="pos-navbar-item">
        <img src="/img/icons/user_profile.svg"
             uk-svg
             width="24"
             height="24">
      </a>

      <NavBarUserMenu></NavBarUserMenu>
    </div>

  </div>
</template>

<script>

  export default {

    name: 'NavBar',

    components: {
      NavBarUserMenu: () => import(/* webpackChunkName: "NavBarUserMenu" */ './NavBarUserMenu')
    },

    data () {
      return {}
    },

    computed: {

      leftToggle () {
        return this.$store.getters.navBarLeftAction
      },

      leftToggleState () {
        return this.$store.getters.cardLeftState
      },

      // заголовок страницы
      pageTitle () {
        if (this.$route.params.title) {
          return '<span class="uk-text-success">' +
            this.$route.meta.breadcrumb + ' - </span> '
            + this.$route.params.title
        } else {
          return this.$route.meta.breadcrumb
        }

      }

    },

    methods: {
      leftToggleAction () {
        this.$store.commit('card_left_show', !this.leftToggleState)
      }
    }
  }
</script>
