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
                 style="object-fit: cover"
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

      <div class="pos-lesson-video__controls">

        <div class="uk-flex-none"
             v-if="selectedPosition">

          <a class="uk-icon-link">
            <img :src="selectedPosition.icon"
                 width="20"
                 height="20"
                 uk-svg>
          </a>

          <div ref="filter"
               class="uk-dropdown-small"
               uk-dropdown="mode: click; pos: top-left; animation: uk-animation-slide-top-small">
            <ul class="uk-grid-small"
                uk-grid>
              <li :class="{'uk-active': selectedPosition === item}"
                  v-for="item in position">
                <a href="#"
                   :class="{'uk-text-danger' : selectedPosition === item, 'uk-link-muted' : selectedPosition !== item}"
                   @click="selectPosition(item)">
                  <img :src="item.icon"
                       width="20"
                       height="20"
                       uk-svg>
                </a></li>
            </ul>
          </div>
        </div>

        <div class="uk-flex-1 uk-text-right">
          <button type="button"
                  @click="shareScreen()"
                  class="uk-button uk-button-default uk-button-small">Screen
          </button>
          <button type="button"
                  @click="getCanvas()"
                  class="uk-button uk-button-default uk-button-small">Canvas
          </button>
          <button type="button"
                  :class="{'uk-active' : selectedRes === 'hd'}"
                  @click="changeRes('hd')"
                  class="uk-button uk-button-default uk-button-small">hd
          </button>
          <button type="button"
                  :class="{'uk-active' : selectedRes === 'sd'}"
                  @click="changeRes('sd')"
                  class="uk-button uk-button-default uk-button-small">sd
          </button>
          <button type="button"
                  :class="{'uk-active' : selectedRes === 'thumb'}"
                  @click="changeRes('thumb')"
                  class="uk-button uk-button-default uk-button-small">thumb
          </button>
        </div>
      </div>

    </div>

    <ListUsers :users="users"/>

    <!--CONTENT-->
    <div class="pos-lesson-teach-content">

      <div class=""
           style="display: flex"
           v-if="rtc && rtc.videoList">

        <div class=""
             v-for="item in rtc.videoList"
             :video="item.id"
             :key="item.id">

          <video width="100"
                 height="100"
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
import ListUsers       from './ListUsers'
import WebRtcInitMulti from '@/api/webRTC/index'

import * as io from 'socket.io-client'

window.io = io
import {appConfig}  from '@/main'

export default {
  name: 'LessonTeach',

  components: {
    //WebRTCScreen,
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

      img: null,

      rtc: null,

      stream: {
        localVideo: null,
        videoList:  null
      },

      users:  null,
      socket: null,

      selectedPosition: null,

      position: [
        {
          v:    'none',
          h:    'none',
          icon: 'img/icons/pos_none.svg'
        },
        {
          v:    'right',
          h:    'top',
          icon: 'img/icons/pos_top-right.svg'
        }, {
          v:    'right',
          h:    'bottom',
          icon: 'img/icons/pos_bottom-right.svg'
        }, {
          v:    'left',
          h:    'bottom',
          icon: 'img/icons/pos_bottom-left.svg'
        }, {
          v:    'left',
          h:    'top',
          icon: 'img/icons/pos_top-left.svg'
        }
      ],

      selectedRes: 'hd',

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

    this.$nextTick(() => {
      this.selectedPosition = this.position[0]
      this.leave()
      this.$store.commit('navBarLeftActionShow', false)
      this.startRTC()
      //this.startRTC()
    })

    // показать кнопку меню в navBar
    //await this.getUsers()
  },

  async beforeDestroy () {
    await this.leave()
    // выгрузка Vuex модуля settings
    this.$store.unregisterModule('lessons')
  },

  async beforeRouteLeave (to, from, next) {
    await this.leave()
    next()
  },

  watch: {
    rtc () {
      if (!this.rtc) {
        this.startRTC()
      }
    }
  },

  methods: {

    // selectedRes
    changeRes (res) {
      this.rtc.changeRes(res)
      this.selectedRes = res
    },

    startRTC () {
      this.rtc = new WebRtcInitMulti(
        appConfig.role,
        'lesson_123',
        appConfig.wssWebRTC,
        appConfig.stunServer,
        appConfig.turnServer
      )
      this.rtc.init(this.$refs.local, this.$refs.video)
      this.getStream()
      this.join()
    },

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

          //this.setConstraints(video.stream)

          this.rtc.videoList.push(video)

          if (stream.type === 'local') {
            this.rtc.localVideo        = video
            this.$refs.local.srcObject = this.rtc.localVideo.stream
          }
        }

        if (this.rtc.localVideo) {
          this.rtc.videoList = this.rtc.videoList
                                   .filter(i => i.id !== this.rtc.localVideo.id)
        }

        setTimeout(() => {
          if (!this.$refs.video) return
          const videoList = this.$refs.video
          //if (videoList.length) return
          const video     = videoList.find(i => i.id === stream.streamid)
          if (!video) return
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

    shareScreen () {
      if (!this.rtc) return
      this.rtc.shareScreen()
    },

    getCanvas () {
      if (!this.rtc) return
      this.rtc.getCanvas(this.$refs.local)
    },

    // move second Video
    moveVideo (direction) {
      switch (direction) {
        case ('none'):
          this.secondScreen.position.v = 'left'
          this.changePositionIndicator('h', 'none')
          break
        case ('left'):
          this.secondScreen.position.v = 'left'
          this.changePositionIndicator('v', 'left')
          break
        case ('right'):
          this.secondScreen.position.v = 'right'
          this.changePositionIndicator('v', 'right')
          break
        case ('top'):
          this.secondScreen.position.h = 'top'
          this.changePositionIndicator('h', 'top')
          break
        case ('bottom'):
          this.secondScreen.position.h = 'bottom'
          this.changePositionIndicator('h', 'bottom')
          break
      }
    },

    changePositionIndicator (direction, pos) {
      if (direction === 'v') {
        this.selectedPosition = this.position.find(i => i.v === pos && i.h === this.secondScreen.position.h)
      }
      else {
        this.selectedPosition = this.position.find(i => i.h === pos && i.v === this.secondScreen.position.v)
      }
    },

    selectPosition (item) {
      this.selectedPosition        = item
      this.secondScreen.position.v = item.v
      this.secondScreen.position.h = item.h
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
