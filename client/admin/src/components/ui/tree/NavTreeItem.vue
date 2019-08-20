<template>
  <div>

    <!--current nav item-->
    <div class="pos-side-nav-item"
         :class="{'uk-active': navActiveId === navItem.id}">

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
              v-if="navItem.table && navItem.table.settings && navItem.table.settings.totalCount"
              v-text="navItem.table.settings.totalCount"></span>
      </a>
      <div class="pos-side-nav-item__actions">

        <!--Добавить дочерний раздел-->
        <a @click.prevent="addChildren(navItem.id)"
           :uk-tooltip="'pos: top-right; delay: 1000; title:' + $t('actions.add')"
           class="pos-side-nav-item-actions__add">
          <img src="/img/icons/icon__plus-doc.svg"
               uk-svg
               width="14"
               height="14"
               alt="">
        </a>

        <!--Редактировать раздел-->
        <a @click.prevent="addChildren(navItem.id)"
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

  export default {

    name: 'NavTreeItem',

    components: {
      'NavTree': () => import('./NavTree')
    },
    props:      {

      navItem: {
        type: Object
      }
    },

    data () {
      return {
        opened: false
      }
    },

    computed: {

      navActiveId () {
        return this.$store.state.cms.cms.activeId
      }
    },

    methods: {

      toggleChildren () {
        this.opened = !this.opened
      },

      addChildren (id) {},

      click (item) {

        if (this.navActiveId !== this.navItem.id) {
          this.$store.commit('cms_table_row_show', false)
          this.$store.commit('tree_active', item.id)
          this.$store.commit('cms_table', item.table)
          this.$emit('close')
          this.$router.push({
            name:   'SettingItem',
            params: {
              id:   item.id,
              item: item
            }
          })
        }

      },

      // remove
      remove (id) {

        this.$store.dispatch('removeTableRow', id)
      }
    }
  }
</script>
