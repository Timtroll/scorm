<template>
  <div class="uk-flex uk-height-1-1 uk-flex-column uk-position-relative"
       v-touch:swipe="swipeLeft">

    <!--Nav tree header-->
    <div class="pos-border-bottom">
      <div class="uk-grid-collapse"
           uk-grid>

        <!--Add Tree root el -->
        <div class="uk-width-auto"
             v-if="add">
          <button type="button"
                  class="uk-button uk-button-success pos-border-radius-none pos-border-none"
                  @click.prevent="addFolder(0)">
            <img src="/img/icons/icon__plus.svg"
                 width="18"
                 height="18"
                 uk-svg>
          </button>
        </div>

        <!--searchInput -->
        <div class="uk-width-expand">
          <div class="uk-position-relative">

            <a @click.prevent="clearSearchVal"
               v-if="searchInput"
               class="uk-form-icon uk-form-icon-flip">
              <img src="/img/icons/icon__close.svg"
                   width="12"
                   height="12"
                   uk-svg>
            </a>

            <div class="uk-form-icon">
              <img src="/img/icons/icon__search.svg"
                   width="14"
                   height="14"
                   uk-svg>
            </div>

            <input class="uk-input pos-border-radius-none pos-border-none"
                   v-model="searchInput"
                   @keyup.esc="clearSearchVal"
                   :placeholder="$t('actions.search')">
          </div>
        </div>

      </div>

    </div>

    <!--Nav tree-->
    <div class="pos-side-nav-container">
      <NavTree :nav="filterSearch"
               :remove="remove"
               :editable="editable"
               :add-children="addChildren"
               v-if="filterSearch.length > 0"/>

      <div class="uk-flex uk-height-1-1 uk-flex-center uk-flex-middle uk-text-center"
           v-else>
        <div>
          <IconBug :size="60"
                   :spin="true"/>
          <p v-html="$t('actions.searchError')"/>
        </div>
      </div>
    </div>

  </div>
</template>

<script>

import {clone, flatTree} from '@/store/methods'

export default {

  components: {
    IconBug: () => import(/* webpackChunkName: "IconBug" */ '../icons/IconBug'),
    Loader:  () => import(/* webpackChunkName: "Loader" */ '../icons/Loader'),
    NavTree: () => import(/* webpackChunkName: "NavTree" */ './NavTree')
  },

  name: 'Tree',

  props: {

    add: {
      type:    Boolean,
      default: true
    },

    openFirst: {
      type:    Boolean,
      default: false
    },

    addChildren: {
      type:    Boolean,
      default: true
    },

    editable: {
      type:    Boolean,
      default: true
    },

    remove: {
      type:    Boolean,
      default: true
    },

    nav: {
      type: Array
    }
  },

  data () {
    return {
      searchInput: null
    }
  },

  watch: {

    // переход на первую ссылку в дереве
    nav () {
      if (!this.nav) return
      if (!this.nav.length) return
      if (this.openFirst) {

        const nav     = this.nav
        const firstId = nav[0]
        this.showTable(firstId)
        //if (this.$route.meta.root) { }
      }
    }
  },

  computed: {

    editPanel_api () { // список запросов для правой панели
      return this.$store.getters.editPanel_api
    },

    tree_api () {
      return this.$store.getters.tree_api
    },

    table_api () {
      return this.$store.getters.table_api
    },

    protoFolder () {
      if (this.tree_api) {
        return this.$store.getters.tree_proto
      }
    },

    // преобразование дерева навигации в один уровень для вывода результатов поиска
    flattenNav () {
      if (this.searchInput) {
        return flatTree(clone(this.nav))
      }
      else {
        return this.nav
      }

    },

    // Поиск по полю label && keywords
    filterSearch () {

      if (!this.flattenNav) return

      return this.flattenNav
                 .filter(item =>
                   !this.searchInput
                   || this.filterProp(item.name)
                   || this.filterProp(item.label)
                   || this.filterProp(item.keywords)
                 )
    }

  },

  methods: {

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
      })
    },

    filterProp (prop) {
      if (!prop) return
      return prop
        .toLowerCase()
        .indexOf(this.searchInput.toLowerCase()) > -1
    },

    async addFolder (parent) {
      this.$store.commit('editPanel_add', true)
      await this.$store.dispatch(this.editPanel_api.addFolderProto, parent)
      this.$store.commit('editPanel_add', true)
      await this.$store.commit('editPanel_folder', true)
    },

    // Очистка поля поиска
    clearSearchVal () {
      this.searchInput = null
    },

    swipeLeft (direction) {
      console.log('tree swipe - ' + direction)
      if (direction === 'left') {
        this.$store.commit('card_left_show', false)
      }
    }
  }
}
</script>
