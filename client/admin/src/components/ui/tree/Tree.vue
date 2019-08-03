<template>
  <div class="uk-flex uk-height-1-1 uk-flex-column">

    <!--searchInput -->
    <div class="uk-margin-small-bottom uk-padding-small pos-border-bottom ">
      <div class="uk-position-relative">
        <a @click.prevent="clearSearchVal"
           v-if="searchInput"
           class="uk-form-icon uk-form-icon-flip">
          <img src="/img/icons/icon__close.svg"
               width="10"
               height="10"
               uk-svg>
        </a>
        <div v-else
             class="uk-form-icon uk-form-icon-flip">
          <img src="/img/icons/icon__search.svg"
               width="14"
               height="14"
               uk-svg>
        </div>

        <input class="uk-input"
               v-model="searchInput"
               @change="filterSearch"
               @keyup.esc="clearSearchVal"
               placeholder="Поиск">
      </div>
    </div>

    <!--Nav tree-->
    <div class="uk-flex-1 uk-overflow-auto uk-padding-small">
      <NavTree :nav="filterSearch"
               v-if="filterSearch.length > 0"
               :active-id="navActiveId"></NavTree>
      <div class="uk-flex uk-height-1-1 uk-flex-center uk-flex-middle uk-text-center"
           v-else>
        <div>
          <IconBug :size="100"
                   :spin="true"></IconBug>
          <p>Это сложно для меня. <br>Говори проще</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import NavTree from './NavTree'
  import IconBug from '../icons/IconBug'

  export default {
    components: {IconBug, NavTree},
    name:       'Tree',
    props:      {
      nav: {
        type: Array
      }
    },

    data () {
      return {
        searchInput: null,
        navActiveId: ''
      }
    },

    computed: {

      // преобразование дерева навигации в один уровень
      flattenNav () {
        if (this.searchInput) {

          const nav        = this.nav
          const flattenNav = []

          const flat = (arr) => {
            arr.forEach((item) => {

              let newItem = {
                label:     item.label,
                id:        item.id,
                component: item.component,
                opened:    item.opened
              }

              flattenNav.push(newItem)

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

      // Поиск по полю label
      filterSearch () {
        return this.flattenNav.filter(item => {
          return !this.searchInput ||
            item.label.toLowerCase().indexOf(this.searchInput.toLowerCase()) > -1
        })
      }

    },

    methods: {

      // Очистка поля поиска
      clearSearchVal () {
        this.searchInput = null
      }
    }
  }
</script>
