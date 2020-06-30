<template>
  <!--CELL-->
  <div class="pos-finder-column">

    <!--CELL HEADER-->
    <div class="pos-finder-column-header uk-grid-collapse"
         uk-grid>

      <!--Add Tree root el -->
      <div class="uk-width-auto"
           v-if="add">
        <button type="button"
                class="uk-button uk-button-success pos-border-radius-none pos-border-none"
                @click.prevent="addEl()">
          <img src="/img/icons/icon__plus.svg"
               width="18"
               height="18"
               uk-svg>
        </button>
      </div>

      <!--searchInput -->
      <div class="uk-width-expand">

        <!-- label-->
        <div class="pos-finder-column-header-label search-toggle uk-flex">

          <div class="uk-flex-1 uk-text-truncate">
            label
          </div>

          <div class="uk-flex-none">
            <a uk-toggle="target: .search-toggle; animation: uk-animation-slide-right"
               href="#">
              <img src="/img/icons/icon__search.svg"
                   width="16"
                   height="16"
                   uk-svg>
            </a>
          </div>
        </div>

        <!--search-->
        <div class="pos-finder-column-header-search search-toggle"
             hidden>

          <a @click.prevent="clearSearchVal"
             uk-toggle="target: .search-toggle; animation: uk-animation-slide-right"
             class="uk-form-icon uk-form-icon-flip">
            <img src="/img/icons/icon__close.svg"
                 width="14"
                 height="14"
                 uk-svg>
          </a>

          <input class="uk-input pos-border-radius-none pos-border-none"
                 v-model="searchInput"
                 @keyup.esc="clearSearchVal"
                 :placeholder="$t('actions.search')">

        </div>

      </div>

    </div>

    <!--CELL BODY-->
    <div class="pos-finder-column-body"></div>
  </div>
  <!-- / CELL-->
</template>

<script>
export default {
  name: 'FinderColumn',

  props: {

    add: {
      type:    Boolean,
      default: false
    },

    editable: {
      type:    Boolean,
      default: true
    },

    remove: {
      type:    Boolean,
      default: true
    },

    data: {
      type:    Object,
      default: () => {}
    }
  },

  data () {
    return {
      searchInput: null
    }
  },

  computed: {

    // Поиск по полю label && keywords
    filterSearch () {

      if (!this.data) return null

      return this.data
                 .filter(item =>
                   !this.searchInput
                   || this.filterProp(item.name)
                   || this.filterProp(item.label)
                   || this.filterProp(item.keywords)
                 )
    }
  },

  methods: {

    filterProp (prop) {
      if (!prop) return
      return prop
        .toLowerCase()
        .indexOf(this.searchInput.toLowerCase()) > -1
    },

    // Очистка поля поиска
    clearSearchVal () {
      this.searchInput = null
    },

    addEl () {}
  }
}
</script>
