<template>
  <!--CELL-->
  <div class="pos-finder-column">

    <!--CELL HEADER-->
    <div class="pos-finder-column-header uk-grid-collapse"
         v-if="data"
         uk-grid>

      <!--Add Tree root el -->
      <div class="uk-width-auto"
           v-if="data.add">
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

          <div class="uk-flex-1 uk-text-truncate"
               v-text="data.label"></div>

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
    <div class="pos-finder-column-body"
         v-if="data && data.list">

      <ul class="pos-finder-list">

        <!--nav item-->
        <li class="pos-finder-list-item"
            v-for="item in filterSearch"
            :class="{selected: item.id === selected}">

          <div class="pos-finder-list-item__label"
               v-text="item.label"
               @click="open(item)"></div>

          <div class="pos-finder-list-item__actions">

            <!--Добавить дочерний раздел-->
            <a @click.prevent="addChildren(item)"
               v-if="data.child.add"
               :uk-tooltip="'pos: top-right; delay: 1000; title:' + $t('actions.add')"
               class="pos-finder-list-item-actions__add">
              <img src="/img/icons/icon__plus-doc.svg"
                   uk-svg
                   width="14"
                   height="14"
                   alt="">
            </a>

            <!--Редактировать раздел-->
            <a @click.prevent="editChildren(item)"
               v-if="data.child.edit"
               :uk-tooltip="'pos: top-right; delay: 1000; title:' + $t('actions.edit')"
               class="pos-finder-list-item-actions__edit">
              <img src="/img/icons/icon__edit.svg"
                   uk-svg
                   width="14"
                   height="14"
                   alt="">
            </a>

            <!--Удалить раздел-->
            <a @click.prevent="removeChildren(item)"
               v-if="data.child.remove"
               :uk-tooltip="'pos: top-right; delay: 1000; title:' + $t('actions.remove')"
               class="pos-finder-list-item-actions__remove">
              <img src="/img/icons/icon__trash.svg"
                   uk-svg
                   width="14"
                   height="14"
                   alt="">
            </a>
          </div>

        </li>
        <!--nav item-->

      </ul>
    </div>
  </div>
  <!-- / CELL-->
</template>

<script>
export default {
  name: 'FinderColumn',

  props: {

    data: {
      type:    Object,
      default: () => {}
    }
  },

  watch: {
    data () {
      this.selected = null
    }
  },

  data () {
    return {
      searchInput: null,
      selected:    null
    }
  },

  computed: {

    // Поиск по полю label && keywords
    filterSearch () {

      if (!this.data) return null
      if (!this.data.list) return null

      return this.data.list.filter(item => !this.searchInput || this.filterProp(item.search))
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

    open (item) {
      this.selected      = item.id
      this.data.selected = item
      this.$emit('open', this.data)
    },

    addEl () {},

    addChildren (item) {},

    removeChildren (item) {},

    editChildren (item) {}

  }
}
</script>
