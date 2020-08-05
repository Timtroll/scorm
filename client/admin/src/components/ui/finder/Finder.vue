<template>
  <div class="pos-finder">

    <FinderColumn v-if="root"
                  :data="root"
                  @open="open($event)"/>

    <FinderColumn v-if="levels"
                  v-for="item in levels"
                  :data="item"
                  @open="item = $event"/>

  </div>
</template>

<script>

export default {
  name:       'Finder',
  components: {
    FinderColumn: () => import(/* webpackChunkName: "FinderColumn" */ './FinderColumn')
  },

  props: {

  },

  data () {
    return {
      dataFiltered: null,
      columns:      []
    }
  },

  computed: {

    root () {
      return this.$store.state.courses.listRoot
    },

    levels () {
      return this.$store.state.courses.list
    }
  },

  methods: {

    getColumns () {
      if (!this.dataFiltered) return []
      if (!this.dataFiltered.selected) return []

      const columns  = []
      const selected = this.dataFiltered.selected
      columns.push(selected)

      _getColumn(this.columns)

      function _getColumn (item) {
        if (item.hasOwnProperty('selected')) {
          console.log('--- i', item)
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
