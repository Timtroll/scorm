<template>
  <div>

    <!--current nav item-->
    <div class="pos-side-nav-item"
         :class="{'uk-active': Number(navActiveId) === navItem.id}">

      <div class="pos-side-nav-item__icon"
           @click.prevent="toggleChildren"
           v-if="navItem.children && navItem.children.length > 0">
        <img uk-img="data-src:/img/icons/icon__minus..svg"
             uk-svg
             v-if="opened">
        <img uk-img="data-src:/img/icons/icon__plus.svg"
             uk-svg
             v-else>
      </div>
      <div class="pos-side-nav-item__no-icon"
           v-else>
      </div>

      <a class="pos-side-nav-item__label"
         @click.prevent="click(navItem)"
         :uk-tooltip="'pos: top-left; delay: 1000; title:' + navItem.label">
        <span class="pos-side-nav-item__label-text"
              v-text="navItem.label"/>

        <!--количество элементов в таблице-->
        <span class="uk-badge pos-side-nav-item__label-badge"
              v-if="navItem.children && navItem.children.length > 0"
              v-text="navItem.children.length"/>
      </a>

      <!--actions-->
      <div class="pos-side-nav-item__actions">

        <!--Добавить дочерний раздел-->
        <a @click.prevent="addChildren(navItem.id)"
           :uk-tooltip="'pos: top-right; delay: 1000; title:' + $t('actions.add')"
           v-if="navItem.folder === 1 && addChildrenItem"
           class="pos-side-nav-item-actions__add">
          <img src="/img/icons/icon__plus-doc.svg"
               uk-svg
               width="14"
               height="14"
               alt="">
        </a>

        <!--Редактировать раздел-->
        <a @click.prevent="editFolder(navItem)"
           :uk-tooltip="'pos: top-right; delay: 1000; title:' + $t('actions.edit')"
           v-if="editable"
           class="pos-side-nav-item-actions__edit">
          <img src="/img/icons/icon__edit.svg"
               uk-svg
               width="14"
               height="14"
               alt="">
        </a>

        <!--Удалить раздел-->
        <a @click.prevent="removeFolder(navItem.id)"
           v-if="removeItem"
           :uk-tooltip="'pos: top-right; delay: 1000; title:' + $t('actions.remove')"
           class="pos-side-nav-item-actions__remove">
          <img src="/img/icons/icon__trash.svg"
               uk-svg
               width="14"
               height="14"
               alt="">
        </a>
      </div>
    </div>

    <!--children nav items-->
    <NavTree v-if="navItem.children && navItem.children.length > 0 && opened"
             :remove-children="remove"
             :editable="editable"
             :add-children="addChildren"
             :nav="navItem.children">
    </NavTree>

  </div>
</template>

<script>
  import {clone, confirm} from '../../../store/methods'

  export default {

    name: 'NavTreeItem',

    components: {
      NavTree: () => import(/* webpackChunkName: "NavTree" */ './NavTree')
    },

    props: {

      navItem: {
        type: Object
      },

      addChildrenItem: {
        type:    Boolean,
        default: true
      },
      editable:        {
        type:    Boolean,
        default: true
      },

      removeItem: {
        type:    Boolean,
        default: true
      }
    },

    mounted () {

      // open tree if children is active
      if (this.navItem && this.navItem.children) {

        const children = clone(this.navItem.children)

        if (children && children.length > 0) {
          this.opened = !!children.find(i => i.id === Number(this.$store.getters.activeId))
        }
      }

    },

    data () {
      return {
        opened: false
      }
    },

    beforeDestroy () {this.$store.commit('page_title', '')},

    computed: {

      tree_api () {
        return this.$store.getters.tree_api
      },

      table_api () {
        return this.$store.getters.table_api
      },

      navActiveId () {
        return this.$store.getters.activeId
      },

      editPanel_api () { // список запросов для правой панели
        return this.$store.getters.editPanel_api
      },

      protoFolder () {
        return this.$store.getters.tree_proto
      },

      cardLeftClickAction () {
        return this.$store.getters.cardLeftClickAction
      },

      cardRightState () { // статус правой панели
        return this.$store.getters.cardRightState
      }

    },

    methods: {

      toggleChildren () {
        this.opened = !this.opened
      },

      click (item) {

        // если folder = 1 -
        if (this.navItem.children && this.navItem.children.length > 0) {

          this.toggleChildren()

        } else {

          if (this.navActiveId !== this.navItem.id) {
            this.showTable(item)

            this.$store.commit('card_left_nav_click')
          }

        }

      },

      // add children group
      addChildren (parent) {
        //const group = {
        //  folder:    1,
        //  lib_id:    id,
        //  label:     '',
        //  name:      '',
        //  editable:  1,
        //  readonly:  0,
        //  removable: 1
        //}
        //
        //this.$store.commit('cms_add_group', group)
        //this.$store.commit('editPanel_group', true)
        //this.$store.commit('cms_show_add_edit_toggle', true)
        //this.$store.commit('editPanel_status_success')
      },

      showTable (item) {
        this.$store.commit('card_right_show', false)
        this.$store.commit('tree_active', item.id)
        this.$store.dispatch(this.table_api.get, item.id)

        this.$router.push({
          name:   this.tree_api.childComponentName,
          params: {
            id:    item.id,
            title: item.label
          }
        }).catch(e => {})
      },

      // edit children group
      async editFolder (folder) {

        if (this.cardRightState) { // если правая панель открыта - закрываем
          this.$store.commit('card_right_show', !this.cardRightState)
        } else {

          await this.$store.dispatch(this.tree_api.edit, this.navItem)
        }

        //if (this.cardRightState) { // если правая панель открыта - закрываем
        //  this.$store.commit('card_right_show', !this.cardRightState)
        //} else {
        //
        //  const proto = await clone(this.protoFolder)
        //  //const proto = await JSON.parse(JSON.stringify(this.protoFolder))
        //
        //  for (let item of proto) {
        //    console.log('item', item)
        //    item.value = folder[item.name]
        //  }
        //
        //  this.$store.commit('editPanel_status_request')
        //  this.$store.commit('editPanel_add', false)
        //  this.$store.commit('editPanel_folder', true)
        //  this.$store.commit('card_right_show', true)
        //
        //  this.$store.commit('editPanel_data', proto) // запись данных во VUEX
        //  this.$store.commit('editPanel_status_success') // статус - успех
        //
        //}

      },

      // remove group
      removeFolder (id) {

        confirm(this.$t('actions.remove'), 'Да', 'Нет')
          .then(() => this.$store.dispatch(this.tree_api.remove, id), () => {})

      }

    }
  }
</script>
