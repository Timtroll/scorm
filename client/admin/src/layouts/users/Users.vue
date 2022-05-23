<template>
  <Card :header="false"
        :footer="false"
        :body-left="true"
        :body-left-show="cardLeft_show"
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
            :add="false"
            :editable="false"
            :open-first="true"
            :remove="false"
            :add-children="false"
            :nav="nav">
      </Tree>
    </template>

    <!--bodyRight-->
    <template #bodyRight>
      <List :labels="'Добавить пользователя'"
            :data="editPanel_data"
            :variable-type-tield="'value'"
            :add="false"
            :folder="editPanel_folder"
            :parent="tableId"
            v-on:save="save($event)"
            v-on:close="closeAddGroup"/>
    </template>

  </Card>
</template>

<script>

import protoLeaf from '@/assets/json/proto/users/leaf.json'
import {clone}   from '@/store/methods'

// import VUEX module groups
import users from '@/store/modules/users'

export default {

  name: 'Users',

  components: {
    IconBug: () => import(/* webpackChunkName: "IconBug" */ '@/components/ui/icons/IconBug'),
    Tree:    () => import(/* webpackChunkName: "Tree" */ '@/components/ui/cmsTree/Tree'),
    NavTree: () => import(/* webpackChunkName: "NavTree" */ '@/components/ui/cmsTree/NavTree'),
    Card:    () => import(/* webpackChunkName: "Card" */ '@/components/ui/card/Card'),
    Loader:  () => import(/* webpackChunkName: "Loader" */ '@/components/ui/icons/Loader'),
    List:    () => import(/* webpackChunkName: "List" */ '@/components/ui/cmsList/List')
  },

  data () {
    return {

      //# управление пользователями
      // '/user/' # список юзеров по группам (обязательно id группы)
      // '/user/add' # добавление юзера
      // '/user/edit' # редактирование юзера
      // '/user/save' # обновление данных юзера
      // '/user/activate' # включение юзера
      // '/user/hide' # отключение юзера
      // '/user/delete' # удаление юзера

      leftNavToggleMobile: false,

      actions: {
        tree: {
          get:                'users/getTree',
          childComponentName: 'UsersItem'
        },

        table: {
          get:       'users/getTable',
          save:      'users/leafSave',
          saveField: 'users/leafSaveField',
          remove:    'users/removeLeaf'
        },

        editPanel: {
          get:      'users/leafEdit',
          save:     'users/leafSave',
          addProto: 'users/leafAdd',
          //addFolderProto: 'users/folderProto',
          add:      'users/leafSave'
        }
      }

    }
  },

  async created () {

    // Регистрация Vuex модуля settings
    await this.$store.registerModule('users', users)

    // показать кнопку меню в navBar
    this.$store.commit('navBarLeftActionShow', true)

    // // запросы
    this.$store.commit('table_api', this.actions.table)
    this.$store.commit('tree_api', this.actions.tree)
    this.$store.commit('editPanel_api', this.actions.editPanel)

    //// запись прототипа из json в store
    this.$store.commit('set_editPanel_proto', protoLeaf)

    //// Получение дерева с сервера
    await this.$store.dispatch(this.actions.tree.get)

    // установка в store Id активного документа
    if (this.tableId) {
      await this.$store.commit('table_current', Number(this.tableId))
    }

    //// Размер панели редактирования
    await this.$store.commit('editPanel_size', false)
    this.$store.commit('card_right_show', false)

    // показать кнопку Добавить
    this.$store.commit('table_addChildren', true)

  },

  beforeDestroy () {

    this.$store.commit('tree_active', null)
    this.$store.commit('set_tree_proto', [])
    this.$store.commit('navBarLeftActionShow', false)
    this.closeEditPanel()
    // выгрузка Vuex модуля settings
    this.$store.unregisterModule('users')
  },

  watch: {

    tableId () {
      //// запись прототипа из json в store
      this.$store.commit('set_editPanel_proto', protoLeaf)
    }
  },

  computed: {

    loader () {
      return this.$store.getters.tree_status
    },

    tableId () {
      return Number(this.$route.params.id)
    },

    editPanel_show () {
      return this.$store.getters.cardRightState
    },

    cardLeft_show () {
      return this.$store.getters.cardLeftState
    },

    editPanel_add () {
      return this.$store.getters.editPanel_add
    },

    editPanel_folder () {
      return this.$store.getters.editPanel_folder
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

    closeEditPanel () {
      this.$store.commit('editPanel_show', false)
      this.$store.commit('set_editPanel_proto', [])
    },

    // Очистка поля поиска
    clearSearchVal () {
      this.table.searchInput = null
    },

    closeAddGroup () {
      this.$store.commit('card_right_show', false)
    },

    save (data) {
      const save = {
        add:    false,
        folder: false,
        fields: {}
      }

      const arr = clone(data)
      arr.forEach(item => {save.fields[item.name] = item.value})

      // преобразование в JSON поля selected
      save.fields.selected = JSON.stringify(save.fields.selected)

      // преобразование в JSON поля value, если тип поля InputDoubleList
      if (save.fields.type === 'InputDoubleList') {
        save.fields.value = JSON.stringify(save.fields.value)
      }

      this.$store.dispatch(this.actions.editPanel.save, save)
    }

  }

}
</script>
