<template>
  <div class="pos-lesson-video">

    <div class="pos-lesson-video-outer">

      <!--main-screen-->
      <div class="pos-lesson-video-screen main-screen">
        <video width="1920"
               ref="teacher"
               height="1080"
               autoplay
               playsinline
               muted>
        </video>
      </div>

      <!--second-screen-->
      <div class="pos-lesson-video-screen second-screen"
           v-if="secondScreen.position.v !== 'none'"
           :class="[secondScreen.position.v, secondScreen.position.h]"
           v-touch:swipe="moveVideo">

        <video width="1920"
               height="1080"
               ref="remote"
               autoplay
               playsinline
               muted
               loop
               preload="auto">
          <!--          :muted="item.muted"-->
          <!--          :id="item.id"-->
        </video>
      </div>

    </div>

    <div class="pos-lesson-video__controls">

      <div class="uk-flex-none"
           v-if="showSecondScreen">

        <a class="uk-icon-link">
          <img v-if="selectedPosition.icon"
               :src="selectedPosition.icon || null"
               width="20"
               height="20"
               uk-svg
               alt="">
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
                     v-if="item.icon"
                     width="20"
                     height="20"
                     uk-svg
                     alt="">
              </a></li>
          </ul>
        </div>
      </div>

      <div class="uk-flex-1 pos-lesson-video__controls-group">

        <a class="uk-icon-link"
           @click.prevent="mute">
          <img src="/img/icons/icon__video-mute.svg"
               width="20"
               height="20"
               uk-svg
               alt=""></a>

        <a class="uk-icon-link"
           @click.prevent="mute">
          <img src="/img/icons/icon__video.svg"
               width="20"
               height="20"
               uk-svg
               alt=""></a>

        <a class="uk-icon-link"
           @click.prevent="mute">
          <img src="/img/icons/icon__mute.svg"
               width="20"
               height="20"
               uk-svg
               alt=""></a>

        <a class="uk-icon-link"
           @click.prevent="unMute">
          <img src="/img/icons/icon__unmute.svg"
               width="20"
               height="20"
               uk-svg
               alt=""></a>
      </div>

      <div class="uk-flex-none uk-text-right">
        <button type="button"
                @click="shareScreen()"
                class="uk-button uk-button-default uk-button-small">Screen
        </button>
        <button type="button"
                @click="getCanvas()"
                class="uk-button uk-button-default uk-button-small">Canvas
        </button>

        <!--        <button type="button"-->
        <!--                :class="{'uk-button-primary' : selectedRes === 'hd'}"-->
        <!--                @click="changeRes('hd')"-->
        <!--                class="uk-button uk-button-default uk-button-small">hd-->
        <!--        </button>-->
        <!--        <button type="button"-->
        <!--                :class="{'uk-button-primary' : selectedRes === 'sd'}"-->
        <!--                @click="changeRes('sd')"-->
        <!--                class="uk-button uk-button-default uk-button-small">sd-->
        <!--        </button>-->
        <!--        <button type="button"-->
        <!--                :class="{'uk-button-primary' : selectedRes === 'thumb'}"-->
        <!--                @click="changeRes('thumb')"-->
        <!--                class="uk-button uk-button-default uk-button-small">thumb-->
        <!--        </button>-->
      </div>
    </div>

  </div>
</template>

<script>
export default {
  name: 'VideoTeachers',

  props: {

    connection: {
      type:    Object,
      default: () => {}
    },

    showSecondScreen: {
      type:    Boolean,
      default: false
    },

    stream: {
      type:    Object,
      default: () => {}
    }
  },

  data () {
    return {
      selectedPosition: {
        v:    'none',
        h:    'none',
        icon: 'img/icons/pos_none.svg'
      },

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

  mounted () {
    if (this.showSecondScreen) {
      this.selectPosition(this.position[0])

      if (this.streamTeacher) {
        this.$refs.teacher.srcObject = this.streamTeacher

      }
    this.join()
    }
  },

  watch: {
    streamTeacher () {
      if (this.streamTeacher) {
        this.$refs.teacher.srcObject = this.streamTeacher
        this.join()
      }
    }
  },

  computed: {

    streamTeacher () {
      if (!this.stream) return
      if (!this.stream.stream) return
      return this.stream.stream.stream
    }
  },

  methods: {

    join () {
      if (!this.connection) return
      this.connection.join()
    },

    // selectedRes
    changeRes (res) {
      //this.rtc.changeRes(res)
      //this.selectedRes = res
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

    mute () {
      //if (!this.rtc) return
      //this.rtc.mute()
    },

    unMute () {
      //if (!this.rtc) return
      //this.rtc.unmute()
    },

    shareScreen () {
      //if (!this.rtc) return
      //this.rtc.shareScreen()
    },

    getCanvas () {
      //if (!this.rtc) return
      //this.rtc.getCanvas(this.$refs.local)
    },


  }
}
</script>
