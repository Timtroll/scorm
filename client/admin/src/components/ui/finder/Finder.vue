<template>
  <div class="pos-finder">

    <FinderColumn v-if="data"
                  :data="data"
                  @open="open($event)"/>

    <FinderColumn v-if="columns"
                  v-for="item in columns"
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

    data: {
      type:    Object,
      default: () => {}
    }
  },

  data () {
    return {
      dataFiltered: null,
      columns:      []
    }
  },

  computed: {},

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
