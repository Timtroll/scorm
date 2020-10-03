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

    <div class="pos-navbar-left">
      <div class="pos-navbar-left-time"
           title="Текущее время">
        <div class="pos-navbar-left-time__item"
             v-text="currentTime.hour"></div>
        <div class="pos-navbar-left-time__item"
             v-text="currentTime.minute"></div>
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
let time

export default {

  name: 'NavBar',

  components: {
    NavBarUserMenu: () => import(/* webpackChunkName: "NavBarUserMenu" */ './NavBarUserMenu')
  },

  mounted () {
    this.getCurrentDate()
  },

  beforeDestroy () {
    clearInterval(time)
  },

  watch: {

    currentDate () {
      const date              = new Date(this.currentDate)
      this.currentTime.hour   = this.setZero(date.getHours())
      this.currentTime.minute = this.setZero(date.getMinutes())
      if (!this.time) {
        this.$store.commit('set_time', this.currentTime)
      }
    },

    'currentTime.minutes' () {
      this.$store.commit('set_time', this.currentTime)
    }

  },

  data () {
    return {
      currentDate: null,
      currentTime: {
        hour:   null,
        minute: null
      }

    }
  },

  computed: {

    time () {
      return this.$store.state.main.time
    },

    leftToggle () {
      return this.$store.getters.navBarLeftAction
    },

    leftToggleState () {
      return this.$store.getters.cardLeftState
    },

    title () {
      return this.$store.state.main.pageTitle
    },

    pageTitle () {
      if (this.title) {
        return this.title
      }
      else {
        return this.titleRoute
      }
    },

    // заголовок страницы
    titleRoute () {
      if (this.$store.state.pageTitle) {
        return this.$store.state.pageTitle
      }
      else if (this.$route.params.title) {
        return '<span class="uk-text-success">' +
          this.$route.meta.breadcrumb + ' - </span> '
          + this.$route.params.title
      }
      else {
        return this.$route.meta.breadcrumb
      }
    }

  },

  methods: {

    setZero (number) {
      return (number < 10) ? `0${number}` : number
    },

    getCurrentDate () {
      time = setInterval(() => {
        this.currentDate = new Date()
        //.toISOString()
        //.toLocaleString('ru')
      }, 1000)
    },

    leftToggleAction () {
      this.$store.commit('card_left_show', !this.leftToggleState)
    }
  }
}
</script>
