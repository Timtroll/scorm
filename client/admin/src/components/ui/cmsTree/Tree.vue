<template>
  <div class="uk-flex uk-height-1-1 uk-flex-column uk-position-relative"
       v-touch:swipe="swipeLeft">

    <!--Nav tree header-->
    <div class="pos-border-bottom">
      <div class="uk-grid-collapse"
           uk-grid>

        <!--Add Tree root el -->
        <div class="uk-width-auto">
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

  import {clone, flatTree} from '../../../store/methods'

  export default {

    components: {
      IconBug: () => import(/* webpackChunkName: "IconBug" */ '../icons/IconBug'),
      Loader:  () => import(/* webpackChunkName: "Loader" */ '../icons/Loader'),
      NavTree: () => import(/* webpackChunkName: "NavTree" */ './NavTree')
    },

    name: 'Tree',

    props: {
      nav: {
        type: Array
      }
    },

    data () {
      return {
        searchInput: null
      }
    },

    computed: {

      //cardLeft_show () {
      //  return this.$store.getters.cardLeftState
      //},

      tree_api () {
        return this.$store.getters.tree_api
      },

      protoFolder () {
        if (this.tree_api) {
          return this.$store.getters.tree_proto
        }
      },

      // преобразование дерева навигации в один уровень для вывода результатов поиска
      flattenNav () {
        if (this.searchInput) {

          return flatTree([...this.nav])

        } else {
          return this.nav
        }

      },

      // Поиск по полю label && keywords
      filterSearch () {

        if (this.flattenNav) {
          return this.flattenNav
                     .filter(item => {
                       return !this.searchInput
                         || item.name
                                .toLowerCase()
                                .indexOf(this.searchInput.toLowerCase()) > -1
                         || item.keywords
                                .toLowerCase()
                                .indexOf(this.searchInput.toLowerCase()) > -1
                     })
        }

      }
    },

    methods: {

      async addFolder (parent) {

        const proto = await clone(this.protoFolder)

        await proto.forEach(item => {
          if (item.name === 'parent') {
            item.value = parent
          }
        })

        await this.$store.commit('card_right_show', false)
        await this.$store.commit('editPanel_data', [])
        await this.$store.commit('editPanel_status_request')
        await this.$store.commit('editPanel_add', true)
        await this.$store.commit('editPanel_folder', true)
        await this.$store.commit('editPanel_data', proto) // запись данных во VUEX
        await this.$store.commit('card_right_show', true)
        await this.$store.commit('editPanel_status_success') // статус - успех
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
