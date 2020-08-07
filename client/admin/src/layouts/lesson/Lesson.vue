<!--
  - Copyright (c) 2020. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
  - Morbi non lorem porttitor neque feugiat blandit. Ut vitae ipsum eget quam lacinia accumsan.
  - Etiam sed turpis ac ipsum condimentum fringilla. Maecenas magna.
  - Proin dapibus sapien vel ante. Aliquam erat volutpat. Pellentesque sagittis ligula eget metus.
  - Vestibulum commodo. Ut rhoncus gravida arcu.
  -->

<template>

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
</style>
