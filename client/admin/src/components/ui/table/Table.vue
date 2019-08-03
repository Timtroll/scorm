<template>
  <div class="uk-overflow-auto uk-height-1-1 uk-position-relative">
    <div class="uk-margin-bottom uk-grid-small uk-flex-right@s"
         uk-grid>

      <div class="uk-width-small@s uk-width-1-1@s ">
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
          <input type="text"
                 v-model="searchInput"
                 @keyup.esc="clearSearchVal"
                 placeholder="Поиск"
                 class="uk-input">
        </div>
      </div>

    </div>
    <table class="uk-table pos-table uk-table-striped uk-table-hover uk-table-divider uk-table-small  uk-table-middle">
      <thead class="pos-table-header">
      <tr>

        <!--header-->
        <th v-for="item in header"
            v-text="item"></th>
        <th class="uk-text-right pos-table-checkbox"
            width="95"
            style="min-width: 95px">
          <input type="checkbox"
                 class="pos-checkbox-switch xsmall">
        </th>
      </tr>
      </thead>
      <tbody>

      <tr v-for="row in data">

        <!--data-->
        <td v-for="item in row"
            class="pos-table-row uk-text-nowrap cursor-pointer"
            @dblclick="edit(row)"
            v-text="item.val"></td>

        <!--check current-->
        <td class="pos-table-checkbox uk-text-right uk-text-nowrap">
          <a class="uk-icon-link uk-margin-small-right uk-display-inline-block"
             @click.prevent="edit(row)">
            <img src="/img/icons/icon__edit.svg"
                 width="16"
                 height="16"
                 uk-svg></a>

          <a class="uk-icon-link uk-link-muted uk-margin-small-right uk-display-inline-block"
             @click.prevent="remove(row)">
            <img height="16"
                 src="/img/icons/icon__trash.svg"
                 uk-svg
                 width="16"></a>
          <input type="checkbox"
                 class="pos-checkbox-switch xsmall">

        </td>
      </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
  export default {
    name: 'Table',

    props: {

      settings: {
        type: Object
      },

      header: {
        type:     Array,
        required: true
      },

      data: {
        type: Array
      }

    },

    data () {
      return {
        searchInput: null
      }
    },

    methods: {

      edit (event) {
        this.$emit('edit', event)
      },

      remove (event) {
        this.$emit('remove', event)
      },

      checkedAll () {
        console.log('checkedAll')
      },

      // Очистка поля поиска
      clearSearchVal () {
        this.searchInput = null
      }
    }
  }
</script>
