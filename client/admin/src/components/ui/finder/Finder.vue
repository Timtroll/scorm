<template>
  <div class="pos-finder">

<!--    <FinderColumn :data="root"-->
<!--                  @open="open($event)"/>-->

    <FinderColumn v-for="(item, index) in levels"
                  :data="item"
                  :key="index"
                  @open="item = $event"/>

  </div>
</template>

<script>

export default {
  name:       'Finder',
  components: {
    FinderColumn: () => import(/* webpackChunkName: "FinderColumn" */ './FinderColumn')
  },

  props: {},

  data () {
    return {
      dataFiltered: null,
      columns:      []
    }
  },

  computed: {

    //root () {
    //  if(!this.$store.state.courses) return
    //  return this.$store.state.courses.listRoot
    //},

    levels () {
      if(!this.$store.state.courses) return
      return this.$store.state.courses.list
    }
  },

  methods: {

    async addEl (route) {
      await this.$store.dispatch('courses/add', {route: route})
    },

    getColumns () {
      if (!this.dataFiltered) return []
      if (!this.dataFiltered.selected) return []

      const columns  = []
      const selected = this.dataFiltered.selected
      columns.push(selected)

      _getColumn(this.columns)

      function _getColumn (item) {
        if (item.hasOwnProperty('selected')) {
          columns.push(item.selected)
          _getColumn(item)
        }
      }

      this.columns = columns
    },

    open (item) {
      this.dataFiltered = item
      this.getColumns()
    },

    openChildren (item) {
      //this.dataFiltered = item
    }
  }

}
</script>

<style lang="sass">
@import "sass/finder"
</style>
