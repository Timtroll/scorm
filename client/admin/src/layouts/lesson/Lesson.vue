<template>
  <div class="pos-lesson-teach">

    <!--VIDEO-->
    <div class="pos-lesson-teach-video">

      <div class="pos-lesson-teach-video-outer">

        <div class="pos-lesson-teach-video-screen main-screen">
          <video width="1920"
                 height="1080"
                 autoplay
                 playsinline
                 muted
                 loop
                 controls
                 preload="auto">
            <source src="https://s3.eu-central-1.amazonaws.com/pipe.public.content/short.mp4">
          </video>
        </div>

        <div class="pos-lesson-teach-video-screen second-screen"
             :class="[secondScreen.position.v, secondScreen.position.h]">
          <video width="1920"
                 height="1080"
                 v-touch:swipe="moveVideo"
                 v-touch-options="{swipeTolerance: 1, touchHoldTolerance: 300}"
                 autoplay
                 playsinline
                 muted
                 loop
                 preload="auto">
            <source src="https://s3.eu-central-1.amazonaws.com/pipe.public.content/short.mp4">
          </video>
        </div>

      </div>

      <div class="pos-lesson-teach-video__controls"></div>

    </div>

    <!--USERS-->
    <div class="pos-lesson-teach-users">

      <div class="pos-lesson-teach-users-header">
        <div class="pos-lesson-teach-users-header__title"
             v-text="$t('lesson.participants')"></div>
      </div>

      <div class="pos-lesson-teach-users-body">
        <ListUsers :users="users"/>
      </div>

    </div>

    <!--CONTENT-->
    <div class="pos-lesson-teach-content">Content</div>
  </div>
</template>

<script>
import lessons from './store'
import ListUsers   from './ListUsers'

/** Examples:
 * https://github.com/webrtc/FirebaseRTC/blob/master/public/app.js
 * https://github.com/openrtc-io/awesome-webrtc
 * https://www.twilio.com/blog/2014/12/set-phasers-to-stunturn-getting-started-with-webrtc-using-node-js-socket-io-and-twilios-nat-traversal-service.html
 * Free Stun-turn server https://www.twilio.com/stun-turn
 * https://www.npmjs.com/package/stun
 * https://github.com/shahidcodes/webrtc-video-call-example-nodejs/blob/master/index.js
 * https://github.com/shahidcodes/webrtc-video-call-example-nodejs/blob/master/index.js
 *
 * free-webrtc-server -
 *    url https://free-webrtc-server.herokuapp.com:8888
 *    docs - https://elements.heroku.com/buttons/florindumitru/signalmaster /
 *           https://github.com/florindumitru/signalmaster
 */
export default {
  name: 'Lesson',

  components: {
    ListUsers
    //componentName: () => import(/* webpackChunkName: "componentName" */ './componentName')
  },

  metaInfo () {
    return {
      title:         'Урок',
      titleTemplate: '%s - ' + this.$t('app.title'),
      htmlAttrs:     {
        lang: this.$t('app.lang')
      }
    }
  },

  props: {
    data: {
      type:    Object,
      default: () => {}
    }
  },

  data () {
    return {

      users: null,

      secondScreen: {
        position: {
          v: 'right',
          h: 'top'
        }
      }
    }
  },

  async created () {
    // Регистрация Vuex модуля settings
    await this.$store.registerModule('lessons', lessons)
  },

  async mounted () {

    // показать кнопку меню в navBar
    this.$store.commit('navBarLeftActionShow', false)
    await this.getUsers()
  },

  beforeDestroy () {

    // выгрузка Vuex модуля settings
    this.$store.unregisterModule('lessons')
  },

  methods: {

    getUsers () {
      const myHeaders = new Headers()
      myHeaders.append('X-API-KEY', '34F47E32-4A194143-B9CAA132-11B6DCFD')

      const formData = new FormData()

      const requestOptions = {
        method:   'POST',
        headers:  myHeaders,
        body:     formData,
        redirect: 'follow'
      }

      fetch('https://uifaces.co/api?limit=25&from_age=8&to_age=16', requestOptions)
        .then(response => response.json())
        .then(result => this.users = result)
        .catch(error => console.log('error', error))
    },

    // move second Video
    moveVideo (direction) {
      switch (direction) {
        case ('left'):
          this.secondScreen.position.v = 'left'
          break
        case ('right'):
          this.secondScreen.position.v = 'right'
          break
        case ('top'):
          this.secondScreen.position.h = 'top'
          break
        case ('bottom'):
          this.secondScreen.position.h = 'bottom'
          break
      }
    }
  }
}
</script>

<style lang="sass">
@import "./sass"
</style>
