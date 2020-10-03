<template>
  <div class="pos-lesson-teach">
    Event Teacher
    <IconConnect :status="connectStatus"
                 :size="32"/>
  </div>
</template>

<script>
export default {
  name: 'EventTeacher',

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

</style>
