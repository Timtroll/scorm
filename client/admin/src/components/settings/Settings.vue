<template>
  <Card :header="false"
        :footer="false"
        :body-left="true"
        :body-left-padding="false"
        :body-left-toggle-show="true"
        :body-right="true"
        :body-padding="false"
        :loader="loader">

    <!-- // Body // -->
    <template #body>

      <transition name="slide-right"
                  mode="out-in"
                  appear>
        <router-view/>
      </transition>

    </template>

    <!--bodyLeft-->
    <template #bodyLeft>
      <Tree v-if="nav"
            :nav="nav"
            @close=""></Tree>
    </template>

  </Card>
</template>

<script>
  import Card from '../ui/card/Card'
  import NavTree from '../ui/tree/NavTree'
  import Tree from '../ui/tree/Tree'
  import IconBug from '../ui/icons/IconBug'
  import Loader from '../ui/icons/Loader'

  export default {

    name: 'Settings',

    components: {IconBug, Tree, NavTree, Card, Loader},

    data () {
      return {}
    },

    created () {
      this.$store.dispatch('getTree')
    },

    beforeDestroy () {
      this.$store.commit('cms_table_row_show', false)
    },

    computed: {

      pageTable () {
        return this.$store.state.cms.navTree.items
      },

      loader () {
        return this.$store.getters.queryStatus
      },

      // Left nav tree
      nav () {
        return this.$store.getters.Settings
      }
    },

    methods: {

      // Очистка поля поиска
      clearSearchVal () {
        this.table.searchInput = null
      }
    }

  }
</script>
