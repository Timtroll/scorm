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
            :data="editPanel_data"
            :variable-type-tield="'value'"
            :add="false"
            v-on:close="closeAddGroup"></List>
    </template>

  </Card>
</template>

<script>

  //import прототипа колонок таблицы
  import protoLeaf from './../../assets/json/proto/settings/leaf.json'

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
            remove: 'removeFolder'
          },

          table: {
            get:      'getTable',
            save:     'saveTableRow',
            remove:   'removeTableRow',
            activate: 'activateTableRow',
            hide:     'hideTableRow'
          },

          editPanel: {
            get:  'getEditPanel',
            save: 'saveEditPanel'
          }
        }

      }
    },

    created () {

      //// Получение дерева с сервера
      this.$store.dispatch(this.actions.tree.get)

      // установка в store Id активного документа
      if (this.tableId) {
        this.$store.commit('table_current', Number(this.tableId))
      }

      // Размер панели редактирования
      this.$store.commit('editPanel_size', false)
      this.$store.commit('table_api', this.actions.table)
      this.$store.commit('tree_api', this.actions.tree)
      this.$store.commit('editPanel_api', this.actions.editPanel)
    },

    async mounted () {
      // Регистрация Vuex модуля settings
      //this.$store.registerModule('settings', settingsVuex)
      this.protoLeaf = await protoLeaf
      this.$store.commit('settings/proto_leaf', protoLeaf)
    },

    beforeDestroy () {
      this.$store.commit('editPanel_show', false)

      // выгрузка Vuex модуля settings
      //this.$store.unregisterModule('settings')
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

      editPanel_data () {
        return this.$store.getters.editPanel_item
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
        this.$store.commit('card_right_show', false)
      }
    }

  }
</script>
