<template>
  <Card :header="false"
        :footer="false"
        :body-left="true"
        :body-left-padding="false"
        :body-left-toggle-show="true"
        :body-right="true"
        :body-right-show="editPanel_show"
        :loader="loader"
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
        leftNavToggleMobile: false,

        actions: {
          tree: {
            get:    'getTree',
            save:   'saveFolder',
            remove: 'removeFolder',
            proto:  this.$store.getters['settings/protoFolder']
          },

          table: {
            get:    'getTable',
            save:   'saveTable',
            remove: 'removeTableRow',
            proto:  'protoTable'
          },

          editPanel: {
            get:    'getTree',
            save:   'saveTree',
            remove: 'removeTree'
          }
        }

      }
    },

    created () {

      this.$store.commit('card_actions', this.actions)

      // Получение дерева с сервера
      this.$store.dispatch(this.actions.tree.get)

      // установка в store Id активного документа
      if (this.tableId) {
        this.$store.commit('table_current', Number(this.tableId))
      }

      // Размер панели редактирования
      this.$store.commit('editPanel_size', false)
    },

    beforeDestroy () {
      this.$store.commit('editPanel_show', false)
    },

    computed: {

      loader () {
        return this.$store.getters.tree_status
      },

      tableId () {
        return this.$route.params.id
      },

      editPanel_show () {
        return this.$store.getters.cardRightState
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
