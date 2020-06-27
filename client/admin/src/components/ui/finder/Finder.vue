<template>
  <div class="pos-finder">

    <FinderColumn :add="true"/>

  </div>
</template>

<script>

export default {
  name:       'Finder',
  components: {
    FinderColumn: () => import(/* webpackChunkName: "FinderColumn" */ './FinderColumn')
  },

  props: {

    data: {
      type:    Object,
      default: () => {}
    }
  },

  data () {
    return {}
  },

  methods: {}
}
</script>

<style lang="sass">
@import "sass/finder"
</style>
