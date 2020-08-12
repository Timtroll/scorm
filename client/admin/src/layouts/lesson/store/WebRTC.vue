<template>
  <div class="pos-lesson-video">

    <div class="pos-lesson-video-outer">

      <div class="pos-lesson-video-screen main-screen">
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

      <div class="pos-lesson-video-screen second-screen"
           v-if="selectedPosition"
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
             uk-dropdown="mode: click; pos: top-left; animation: uk-animation-slide-top-small">
          <ul class="uk-grid-small"
              uk-grid>
            <li :class="{'uk-active': selectedPosition === item}"
                v-for="item in position">
              <a href="#"
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
export default {
  name: 'WebRTC',

  components: {
    //componentName: () => import(/* webpackChunkName: "componentName" */ './componentName')
  },

  props: {
    data: {
      type:    Object,
      default: () => {}
    }
  },

  data () {
    return {
      selectedPosition: null,

      position: [
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

  async mounted () {
    this.selectedPosition = this.position[0]
  },

  methods: {

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
    },

    selectPosition (item) {
      this.selectedPosition        = item
      this.secondScreen.position.v = item.v
      this.secondScreen.position.h = item.h
    }
  }
}
</script>
