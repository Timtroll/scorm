<template>
  <div class="pos-finder">

    <FinderColumn v-if="data"
                  :data="data"
                  :add="true"/>

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
  }

}
</script>

<style lang="sass">
@import "sass/finder"
</style>
