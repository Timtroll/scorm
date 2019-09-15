<template>
  <Card :header="false"
        :footer="false"
        :body-left="true"
        :body-left-padding="false"
        :body-left-toggle-show="true"
        :body-right="true"
        :body-right-show="pageTableAddGroupShow"
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
            :nav="nav">
      </Tree>
    </template>

    <!--bodyRight-->
    <template #bodyRight>
      <List :row-data="pageTableAddGroupData"
            :labels="'Добавить группу настроек'"
            :add="pageTableAddEditGroup"
            :group="true"
            v-on:close="closeAddGroup"></List>
    </template>

  </Card>
</template>

<script>
  import Card from '../ui/card/Card'
  import NavTree from '../ui/tree/NavTree'
  import Tree from '../ui/tree/Tree'
  import IconBug from '../ui/icons/IconBug'
  import Loader from '../ui/icons/Loader'
  import List from '../ui/list/List'

  export default {

    name: 'Settings',

    components: {
      IconBug,
      Tree,
      NavTree,
      Card,
      Loader,
      List
    },

    data () {
      return {
        leftNavToggleMobile: false
      }
    },

    created () {
      this.$store.dispatch('getTree')
    },

    beforeDestroy () {
      this.$store.commit('cms_table_row_show', false)
    },

    computed: {

      pageTableAddGroupShow () {
        return this.$store.getters.pageTableAddGroupShow
      },

      pageTableAddGroupData () {
        return this.$store.getters.pageTableAddGroupData
      },

      pageTableAddEditGroup () {
        return this.$store.getters.pageTableAddEditGroup
      },

      pageTable () {
        return this.$store.state.cms.navTree.items
      },

      loader () {
        return this.$store.getters.queryStatus
      },

      // Left nav tree
      nav () {
        return this.$store.getters.Settings
      },

      cardLeftClickAction () {
        return this.$store.getters.cardLeftClickAction
      }

    },

    methods: {

      // Очистка поля поиска
      clearSearchVal () {
        this.table.searchInput = null
      },

      closeAddGroup () {
        this.$store.commit('cms_show_add_group', false)
      }
    }

  }
</script>
