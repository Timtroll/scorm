<template>
  <Card :header="false"
        :footer="false"
        :body-left="true"
        :body-left-padding="false"
        :body-left-toggle-show="true"
        :body-right="true"
        :body-padding="false"
        :body-left-action-event="card.bodyLeftShow"
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
            :nav="nav"></Tree>
    </template>

  </Card>
</template>

<script>
  import Card from '../ui/card/Card'
  import NavTree from '../ui/tree/NavTree'
  import Tree from '../ui/tree/Tree'
  import IconBug from '../ui/icons/IconBug'
  import Table from '../ui/table/Table'

  export default {

    name: 'Settings',

    components: {Table, IconBug, Tree, NavTree, Card},

    data () {
      return {

        bodyComponent: null,
        card:          {
          //bodyLeftShow:     true,
          bodyRightShow:    false,
          bodyRightContent: []
        }

      }
    },

    created () {

      // Get left nav tree
      //this.$store.dispatch('getNavTree')

      // cms
      this.$store.dispatch('getTree')
    },

    computed: {

      pageTable () {
        return this.$store.state.cms.navTree.items
      },

      bodyLeftShow () {
        return this.$store.getters.cardLeftState
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

      //bodyLeftActionEvent () {
      //  this.$store.commit('setNavbarLeftActionState', !this.bodyLeftShow)
      //  //this.card.bodyLeftShow = !this.card.bodyLeftShow
      //},

      editEl (event) {
        this.card.bodyRightContent = event
        this.card.bodyRightShow    = !this.card.bodyRightShow
      },

      removeEl () {},

      // Очистка поля поиска
      clearSearchVal () {
        this.table.searchInput = null
      }
    }

  }
</script>
