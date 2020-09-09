<template>
  <div class="uk-height-1-1 uk-width-1-1 uk-grid uk-grid-collapse uk-overflow-auto">

    <!--logo - desktop-->
    <div
      class="uk-width-1-1 uk-width-auto@s uk-width-1-2@l uk-flex uk-flex-center uk-height-viewport uk-flex-middle uk-flex-center uk-flex-right@m uk-background-default uk-visible@m">
      <div class="uk-section">
        <div class="uk-container uk-text-center pos-login-logo-left"
             :class="[status === 'loading' ? 'uk-text-danger' : '']">
          <img :src="appConfig.logo"
               width="100"
               class=""
               uk-svg>
          <div class="uk-margin-small-top"
               v-text="appConfig.title"></div>
        </div>
      </div>
    </div>

    <div
      class="uk-width-1-1 uk-width-expand@s uk-width-1-2@l uk-flex uk-flex-center uk-height-viewport uk-flex-middle uk-flex-center uk-flex-left@l"
      :class="[status !== 'loading' ? background.default : background.loading]">
      <div class="uk-section uk-light uk-flex uk-flex-middle uk-height-1-1"
           style="overflow-x: visible; overflow-y: auto">

        <transition name="fade"
                    mode="out-in">
          <router-view/>
        </transition>

      </div>
    </div>

  </div>
</template>
<script>
import {appConfig} from '@/main'

export default {

  name: 'Sign',

  data () {

    return {
      appConfig: null,

      direction: false,
      motion:    false,

      user: {
        login:    '',
        password: ''
      },

      background: {
        default: 'pos-login-background',
        loading: 'uk-background-danger'
      }

    }

  },

  beforeMount () {
    this.appConfig = appConfig
  },

  computed: {

    status () {
      return this.$store.getters.authStatus
    }
  }

}
</script>
