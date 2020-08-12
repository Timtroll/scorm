<template>
  <div class="pos-lesson-teach">

    <!--VIDEO-->
    <WebRTC/>

    <ListUsers :users="users"/>

    <!--CONTENT-->
    <div class="pos-lesson-teach-content">Content</div>
  </div>
</template>

<script>
import lessons   from './store'
import ListUsers from './ListUsers'
import WebRTC    from '@/layouts/lesson/store/WebRTC'

/** Examples:
 * https://github.com/webrtc/FirebaseRTC/blob/master/public/app.js
 * https://github.com/openrtc-io/awesome-webrtc
 * https://www.twilio.com/blog/2014/12/set-phasers-to-stunturn-getting-started-with-webrtc-using-node-js-socket-io-and-twilios-nat-traversal-service.html
 * Free Stun-turn server https://www.twilio.com/stun-turn | Google's public STUN server (stun.l.google.com:19302)
 * https://www.npmjs.com/package/stun
 * https://github.com/shahidcodes/webrtc-video-call-example-nodejs/blob/master/index.js
 *https://www.html5rocks.com/en/tutorials/webrtc/infrastructure/
 *
 * https://github.com/simplewebrtc/SimpleWebRTC
 * free-webrtc-server - SimpleWebRTC
 *    url https://free-webrtc-server.herokuapp.com:8888
 *    docs - https://elements.heroku.com/buttons/florindumitru/signalmaster /
 *           https://github.com/florindumitru/signalmaster
 */
export default {
  name: 'Lesson',

  components: {
    WebRTC,
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
    }

  }
}
</script>

<style lang="sass">
@import "./sass"
</style>
