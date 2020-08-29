<template>
  <div class="uk-height-1-1 uk-width-1-1 uk-grid uk-grid-collapse">

    <!--logo - desktop-->
    <div
      class="uk-width-1-1 uk-width-auto@s uk-width-1-2@l uk-flex uk-flex-center uk-height-viewport uk-flex-middle uk-flex-center uk-flex-right@m uk-background-default uk-visible@m">
      <div class="uk-section">
        <div class="uk-container uk-text-center pos-login-logo-left"
             :class="[status === 'loading' ? 'uk-text-danger' : '']">
          <img src="/img/logo__bw.svg"
               width="100"
               class=""
               uk-svg>
          <div class="uk-margin-small-top"
               v-text="$t('app.title')"></div>
        </div>
      </div>
    </div>

    <transition name="fade"
                mode="out-in">
      <router-view/>
    </transition>

  </div>
</template>
<script>

export default {

  name: 'Sign',

  data () {

    return {

      direction: false,
      motion:    false,

      user: {
        login: '',
        pass:  ''
      },

      background: {
        default: 'pos-login-background',
        loading: 'uk-background-danger'
      }

    }

  },

  computed: {

    status () {
      return this.$store.getters.authStatus
    }
  }

}
</script>
