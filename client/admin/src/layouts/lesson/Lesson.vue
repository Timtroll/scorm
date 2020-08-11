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

      <div class="pos-lesson-teach-video__controls"></div>

    </div>

    <!--USERS-->
    <div class="pos-lesson-teach-users">

      <div class="pos-lesson-teach-users-header">
        <div class="pos-lesson-teach-users-header__title"
             v-text="$t('lesson.participants')"></div>
      </div>

      <div class="pos-lesson-teach-users-body">
      </div>

    </div>

    <!--CONTENT-->
    <div class="pos-lesson-teach-content">Content</div>
  </div>
</template>

<script>
export default {
  name: 'Lesson',

  components: {
    //componentName: () => import(/* webpackChunkName: "componentName" */ './componentName')
  },

  metaInfo () {
    return {
      title:         'Lesson',
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
      secondScreen: {
        position: {
          v: 'right',
          h: 'top'
        }
      }
    }
  },

  methods: {

    // moveVideo
    moveVideo (direction) {
      console.log(direction)
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

<style lang="sass"
       scoped>
@import "./src/assets/sass/layouts/lessons"
</style>
