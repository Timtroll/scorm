<template>
  <div>

    <!--current nav item-->
    <div class="pos-side-nav-item"
         :class="{'uk-active': Number(navActiveId) === navItem.id}">

      <div class="pos-side-nav-item__icon"
           @click="toggleChildren"
           v-if="navItem.children && navItem.children.length > 0">
        <img src="/img/icons/icon__minus.svg"
             uk-svg
             v-if="opened">
        <img src="/img/icons/icon__plus.svg"
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
              v-text="navItem.label"></span>

        <!--количество элементов в таблице-->
        <span class="uk-badge pos-side-nav-item__label-badge"
              v-if="navItem.children && navItem.children.length > 0"
              v-text="navItem.children.length"></span>
      </a>

      <!--actions-->
      <div class="pos-side-nav-item__actions">

        <!--Добавить дочерний раздел-->
        <a @click.prevent="addChildren(navItem.id)"
           :uk-tooltip="'pos: top-right; delay: 1000; title:' + $t('actions.add')"
           v-if="navItem.folder === 1"
           class="pos-side-nav-item-actions__add">
          <img src="/img/icons/icon__plus-doc.svg"
               uk-svg
               width="14"
               height="14"
               alt="">
        </a>

        <!--Редактировать раздел-->
        <a @click.prevent="editGroup(navItem)"
           :uk-tooltip="'pos: top-right; delay: 1000; title:' + $t('actions.edit')"
           class="pos-side-nav-item-actions__edit">
          <img src="/img/icons/icon__edit.svg"
               uk-svg
               width="14"
               height="14"
               alt="">
        </a>

        <!--Удалить раздел-->
        <a @click.prevent="remove(navItem.id)"
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
             :nav="navItem.children">
    </NavTree>

  </div>
</template>

<script>
  import UIkit from 'uikit/dist/js/uikit.min'

  export default {

    name: 'NavTreeItem',

    components: {
      NavTree: () => import('./NavTree')
    },

    props: {
      navItem: {
        type: Object
      }
    },

    mounted () {

      // open tree if children is active
      if (this.navItem && this.navItem.children) {
        const children = [...this.navItem.children]

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

    beforeDestroy () {
      this.$store.commit('page_title', '')
    },

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

      cardLeftClickAction () {
        return this.$store.getters.cardLeftClickAction
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

            this.$store.commit('card_right_show', false)
            this.$store.commit('tree_active', item.id)
            this.$store.dispatch(this.table_api.get, item.id)

            this.$router.push({
              name:   'SettingItem',
              params: {
                id:    item.id,
                title: item.label
              }
            })

          }

          this.$store.commit('card_left_nav_click', !this.cardLeftClickAction)

        }

      },

      // add children group
      addChildren (id) {
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

      // edit children group
      editGroup (item) {
        //const group = {
        //  folder:    1,
        //  lib_id:    item.id,
        //  label:     item.label,
        //  name:      item.name,
        //  editable:  item.editable,
        //  readonly:  0,
        //  removable: 1
        //}
        //
        //this.$store.commit('cms_add_group', group)
        //this.$store.commit('editPanel_group', true)
        //this.$store.commit('cms_show_add_edit_toggle', false)
        //this.$store.commit('editPanel_status_success')
      },

      // remove group
      remove (id) {

        UIkit
          .modal
          .confirm('Удалить', {labels: {ok: 'Да', cancel: 'Отмена'}})
          .then(() => this.$store.dispatch(this.tree_api.remove, id), () => {})

      }

    }
  }
</script>
