<template>
  <div class="pos-lesson-video" v-if="config">

    <div class="pos-lesson-video-outer">

      <div class="pos-lesson-video-screen main-screen">

        <vue-webrtc ref="webrtc"
                    :cameraHeight="160"
                    :roomId="roomId"
                    :socketURL="'wss://rtcmulticonnection.herokuapp.com/socket.io/'"
                    v-on:joined-room="logEvent"
                    v-on:left-room="logEvent"
                    v-on:opened-room="logEvent"
                    v-on:share-started="logEvent"
                    v-on:share-stopped="logEvent"
                    @error="onError"/>


<!--        :stunServer="config.stunServer"-->
<!--        :turnServer="config.turnServer"-->


        <!--        :socketURL="'wss://freee.su/wschannel/'"-->
        <!--        :stun-server="'https://free-webrtc-server.herokuapp.com'"-->
        <!--        :turn-server="'https://free-webrtc-server.herokuapp.com'"-->
        <!--        <video width="1920"-->
        <!--               height="1080"-->
        <!--               autoplay-->
        <!--               playsinline-->
        <!--               muted-->
        <!--               loop-->
        <!--               controls-->
        <!--               preload="auto">-->
        <!--          <source src="https://s3.eu-central-1.amazonaws.com/pipe.public.content/short.mp4">-->
        <!--        </video>-->
      </div>

      <div class="pos-lesson-video-screen second-screen"
           v-if="selectedPosition && selectedPosition.v !== 'none'"
           :class="[secondScreen.position.v, secondScreen.position.h]">
        <video width="1920"
               height="1080"
               v-touch:swipe="moveVideo"
               v-touch-options="{swipeTolerance: 10, touchHoldTolerance: 300}"
               autoplay
               playsinline
               muted
               loop
               preload="auto">
          <source src="https://s3.eu-central-1.amazonaws.com/pipe.public.content/short.mp4">
        </video>
      </div>

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
    </div>

  </div>
</template>

<script>
import {WebRTC}   from 'vue-webrtc'
import * as io    from 'socket.io-client'

window.io    = io


export default {
  name: 'WebRTCScreen',

  components: {
    'vue-webrtc': WebRTC
    //componentName: () => import(/* webpackChunkName: "componentName" */ './componentName')
  },

  props: {
    config:{
      type:    Object,
      default: () => {}
    },
    data: {
      type:    Object,
      default: () => {}
    }
  },

  data () {
    return {
      img:    null,
      roomId: 'lesson',

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

      secondScreen: {
        position: {
          v: 'right',
          h: 'top'
        }
      }
    }
  },

  //computed: {
  //  config () {
  //    return this.$store.state.main.config.webRTC || null
  //  }
  //},

  async mounted () {
    this.selectedPosition = this.position[0]
    this.onJoin()
  },

  beforeDestroy () {
    this.onLeave()
  },

  methods: {

    onCapture () {
      this.img = this.$refs.webrtc.capture()
    },

    onJoin () {
      this.$refs.webrtc.join()
    },

    onLeave () {
      this.$refs.webrtc.leave()
    },

    onShareScreen () {
      this.img = this.$refs.webrtc.shareScreen()
    },

    onError (error, stream) {
      console.log('On Error Event', error, stream)
    },

    logEvent (event) {
      console.log('Event : ', event)
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
    }
  }
}
</script>
