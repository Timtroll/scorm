<template>
  <div class="pos-lesson-teach">

    <div class="pos-lesson-loader">
      <IconConnect :status="connectStatus"
                   :size="48"/>
      Student
    </div>

  </div>
</template>

<script>
export default {

  name: 'EventStudent',

  components: {
    IconConnect: () => import(/* webpackChunkName: "IconConnect" */  '@/components/ui/icons/IconConnect')
  },

  props: {
    data: {
      type:    Object,
      default: () => {}
    }
  },

  data () {
    return {
      connectStatus: 'progress'
    }
  }
}
</script>

<style lang="sass">
@import "sass"
</style>
