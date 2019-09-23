<template>
  <Card :header="false"
        :footer="false"
        :body-left="true"
        :body-left-padding="false"
        :body-left-toggle-show="true"
        :body-right="true"
        :body-right-show="pageTableAddGroupShow"
        :body-padding="false">

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
      <List :labels="'Добавить группу настроек'"
            :group="true"
            v-on:close="closeAddGroup"></List>
    </template>

  </Card>
</template>

<script>

  // Mock
  const TreeData = require('./../../assets/mock/navTree')

  export default {

    name: 'Settings',

    components: {
      IconBug: () => import('../ui/icons/IconBug'),
      Tree:    () => import('../ui/cmsTree/Tree'),
      NavTree: () => import('../ui/cmsTree/NavTree'),
      Card:    () => import('../ui/card/Card'),
      Loader:  () => import('../ui/icons/Loader'),
      List:    () => import('../ui/cmsList/List')
    },

    data () {
      return {
        leftNavToggleMobile: false

      }
    },

    created () {
      this.$store.commit('set_tree', TreeData)
      this.$store.commit('tree_status_success')
      //this.$store.dispatch('getTree')
    },

    beforeDestroy () {
      this.$store.commit('editPanel_show', false)
    },

    computed: {

      loader () {
        return this.$store.getters.tree_status
      },

      pageTableAddGroupShow () {
        return this.$store.getters.pageTableAddGroupShow
      },

      // Left nav tree
      nav () {
        return this.$store.getters.tree
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
        this.$store.commit('editPanel_group', false)
      }
    }

  }
</script>
