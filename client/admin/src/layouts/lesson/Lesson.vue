<template>
  <div class="pos-lesson-teach">

    <!--VIDEO-->
    <!--    <WebRTCScreen />-->
    <!--    <WebRTCScreen v-if="config"-->
    <!--                  :config="config"/>-->

    <div class="pos-lesson-video">

      <div class="pos-lesson-video-outer">
        <div class="pos-lesson-video-screen main-screen">
          <video width="1920"
                 ref="local"
                 height="1080"
                 autoplay
                 playsinline
                 muted
                 loop>
          </video>
        </div>

        <!--        <div class="pos-lesson-video-screen second-screen">-->
        <!--          <video width="1920"-->
        <!--                 height="1080"-->
        <!--                 ref="remote"-->
        <!--                 autoplay-->
        <!--                 playsinline-->
        <!--                 muted-->
        <!--                 loop-->
        <!--                 preload="auto"-->
        <!--                 :muted="item.muted"-->
        <!--                 :id="item.id">-->
        <!--          </video>-->
        <!--        </div>-->

      </div>

    </div>

    <!--    <ListUsers :users="users"/>-->

    <!--CONTENT-->
    <div class="pos-lesson-teach-content">

      <div class=""
           v-if="rtc && rtc.videoList">

        <div class=""
             v-for="item in rtc.videoList"
             :video="item.id"
             :key="item.id">

          <video width="128"
                 height="72"
                 ref="video"
                 autoplay
                 playsinline
                 muted
                 loop
                 :muted="item.muted"
                 :id="item.id">
          </video>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import lessons         from './store'
//import ListUsers    from './ListUsers'
//import WebRTCScreen from '@/layouts/lesson/WebRTCScreen'
import WebRtcInitMulti from '@/api/webRTC/index'
//import Socket       from '@/api/socket/webRtc'
//require('adapterjs')

//import adapter from 'webrtc-adapter'

//console.log(adapter.browserDetails)

import * as io from 'socket.io-client'

window.io = io

/** Examples:
 * https://github.com/webrtc/FirebaseRTC/blob/master/public/app.js
 * https://github.com/openrtc-io/awesome-webrtc
 * https://www.twilio.com/blog/2014/12/set-phasers-to-stunturn-getting-started-with-webrtc-using-node-js-socket-io-and-twilios-nat-traversal-service.html
 * Free Stun-turn server https://www.twilio.com/stun-turn | Google's public STUN server (stun.l.google.com:19302)
 * https://www.npmjs.com/package/stun
 * https://github.com/shahidcodes/webrtc-video-call-example-nodejs/blob/master/index.js
 * https://www.html5rocks.com/en/tutorials/webrtc/infrastructure/
 *
 * https://github.com/simplewebrtc/SimpleWebRTC
 * free-webrtc-server - SimpleWebRTC
 *    url https://free-webrtc-server.herokuapp.com:8888
 *    docs - https://elements.heroku.com/buttons/florindumitru/signalmaster/
 *           https://github.com/florindumitru/signalmaster
 *
 * https://rtcmulticonnection.herokuapp.com/demos/
 *
 * https://github.com/versatica/mediasoup/
 */
export default {
  name: 'Lesson',

  components: {
    //WebRTCScreen,
    //ListUsers
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

      rtc: null,

      stream: {
        localVideo: null,
        videoList:  null
      },

      users:  null,
      socket: null
    }
  },

  async created () {
    // Регистрация Vuex модуля settings
    await this.$store.registerModule('lessons', lessons)
  },

  async mounted () {
    this.leave()
    this.$store.commit('navBarLeftActionShow', false)

    this.$nextTick(() => {
      this.rtc = new WebRtcInitMulti('lector')
      this.rtc.init(this.$refs.local, this.$refs.video)
      this.getStream()

      this.join()

    })

    // показать кнопку меню в navBar
    //await this.getUsers()
  },

  beforeDestroy () {
    this.leave()
    // выгрузка Vuex модуля settings
    this.$store.unregisterModule('lessons')
  },

  methods: {

    getStream () {
      if (!this.rtc.rtcmConnection) return

      this.rtc.rtcmConnection.onstream = (stream) => {

        let found = this.rtc.videoList.find(video => {
          return video.id === stream.streamid
        })

        if (found === undefined) {
          const video = {
            id:     stream.streamid,
            muted:  stream.type === 'local',
            stream: stream.stream
          }

          this.rtc.videoList.push(video)

          if (stream.type === 'local') {
            this.rtc.localVideo = video
            this.$refs.local.srcObject = this.rtc.localVideo.stream
          }

        }

        if (this.rtc.localVideo) {
          this.rtc.videoList = this.rtc.videoList.filter(i => i.id !== this.rtc.localVideo.id)
        }

        setTimeout(() => {
          if (!this.$refs.video) return
          const videoList = this.$refs.video
          if (videoList.length) return
          const video     = videoList.find(i => i.id === stream.streamid)
          video.srcObject = stream.stream
        }, 1000)

        console.log('joined-room', stream)
      }

      this.rtc.rtcmConnection.onstreamended = (stream) => {
        const newList = []

        this.rtc.videoList.forEach((item) => {
          if (item.id !== stream.streamid) {
            newList.push(item)
          }
        })

        this.rtc.videoList = newList
        console.log('left-room', stream.streamid)
      }
    },

    leave () {
      if (!this.rtc) return
      this.rtc.leave()
    },

    join () {
      if (!this.rtc) return
      this.rtc.join()
    },

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
