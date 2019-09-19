<template>
  <div class="uk-flex uk-height-1-1 uk-flex-column">

    <!--Nav tree header-->
    <div class="pos-border-bottom">
      <div class="uk-grid-collapse"
           uk-grid>

        <!--Add Tree root el -->
        <div class="uk-width-auto">
          <button type="button"
                  class="uk-button uk-button-success pos-border-radius-none pos-border-none"
                  @click.prevent="addRoot">
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
               v-if="filterSearch.length > 0"></NavTree>
      <div class="uk-flex uk-height-1-1 uk-flex-center uk-flex-middle uk-text-center"
           v-else>
        <div>
          <IconBug :size="100"
                   :spin="true"></IconBug>
          <p v-html="$t('actions.searchError')"></p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import IconBug from '../icons/IconBug'

  export default {

    components: {
      IconBug,
      NavTree: () => import('./NavTree')
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

      // преобразование дерева навигации в один уровень
      // для вывода результатов поиска
      flattenNav () {
        if (this.searchInput) {

          const nav        = [...this.nav]
          const flattenNav = []

          const flat = (arr) => {
            arr.forEach((item) => {

              let newItem = {
                label:     item.label,
                id:        item.id,
                keywords:  item.keywords,
                folder:    item.folder,
                component: item.component,
                opened:    item.opened,
                children:  item.children
              }

              if (item.folder !== 1) {
                flattenNav.push(newItem)
              }

              if (item.children && item.children.length > 0) {
                flat(item.children)
              }
            })
          }

          flat(nav)

          return flattenNav

        } else {
          return this.nav
        }

      },

      // Поиск по полю label && keywords
      filterSearch () {

        return this.flattenNav
                   .filter(item => {
                     return !this.searchInput
                       || item.label
                              .toLowerCase()
                              .indexOf(this.searchInput.toLowerCase()) > -1
                       || item.keywords
                              .toLowerCase()
                              .indexOf(this.searchInput.toLowerCase()) > -1
                   })

      }
    },

    methods: {

      addRoot () {},

      // Очистка поля поиска
      clearSearchVal () {
        this.searchInput = null
      }
    }
  }
</script>
