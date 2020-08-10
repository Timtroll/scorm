<template>
  <div class="pos-lesson-teach">
    <div class="pos-lesson-teach-video">
      <canvas width="1920" height="1080"></canvas>
    </div>
    <div class="pos-lesson-teach-users"></div>
    <div class="pos-lesson-teach-content"></div>
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
    return {}
  }
}
</script>

<style lang="sass"
       scoped>
@import "./src/assets/sass/layouts/lessons"
</style>
