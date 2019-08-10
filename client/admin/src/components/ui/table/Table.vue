<template>
  <Card :footer="false"
        :header="true"
        :header-large="false"
        :header-bgr-default="true"
        :header-left="true"
        :footer-right="false"
        :body-padding="true">

    <template #headerLeft>
      <div class="uk-grid-small"
           uk-grid>

        <!--Add Row-->
        <div>
          <button type="button"
                  class="uk-button uk-button-success uk-button-small">
            <img src="/img/icons/icon__plus.svg"
                 width="16"
                 height="16"
                 uk-svg>
            <span class="uk-margin-small-left uk-visible@m"
                  v-text="$t('actions.add')"></span>
          </button>
        </div>

        <!--Remove Row-->
        <div>
          <button class="uk-button-danger uk-button uk-button-small"
                  disabled>
            <img src="/img/icons/icon__trash.svg"
                 uk-svg
                 width="10"
                 height="10">
            <span class="uk-margin-small-left uk-visible@s"
                  v-text="$t('actions.remove')"></span>
          </button>
        </div>
      </div>

    </template>

    <template #header>

      <ul class="uk-pagination uk-margin-remove"
          uk-margin>
        <li><a href="#">
          <span uk-pagination-previous></span>
        </a></li>
        <li><a href="#">1</a></li>
        <li class="uk-active">
          <span>4</span>
        </li>
        <li><a href="#">8</a></li>
        <li><a href="#">
          <span uk-pagination-next></span>
        </a></li>
      </ul>

      <!--table searchInput-->
      <div class="uk-position-relative uk-width-medium uk-margin-auto-left">
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
               class="uk-input uk-form-small">
      </div>
    </template>

    <!--body-->
    <template #body>

      <div class="pos-table-container">
        <table v-if="table"
               class="uk-table pos-table uk-table-striped uk-table-hover uk-table-divider uk-table-small  uk-table-middle">

          <!--header-->
          <thead class="pos-table-header">
          <tr>
            <!--expand Row-->
            <th class="pos-table-expand">
              <div style="width: 16px">
                <img src="/img/icons/icon__expand.svg"
                     width="16"
                     height="16"
                     uk-svg>
              </div>
            </th>

            <!--header rows data-->
            <th v-for="item in table.header"
                v-text="item.label"></th>
            <th class="uk-text-right pos-table-checkbox">
              <!--edit Row-->
              <span class="uk-margin-small-right uk-display-inline-block">
            <img src="/img/icons/icon__edit.svg"
                 width="16"
                 height="16"
                 uk-svg></span>

              <!--remove Row-->
              <span class="uk-margin-small-right uk-display-inline-block">
            <img height="16"
                 src="/img/icons/icon__trash.svg"
                 uk-svg
                 width="16"></span>

              <span>
            <input type="checkbox"
                   v-model="checked"
                   @click="checkedAll"
                   class="pos-checkbox-switch xsmall">
            </span>
            </th>
          </tr>
          </thead>
          <tbody>

          <TableRow
              :row-data="row"
              :checked-all="checked"
              v-for="(row, index) in tableRows"
              v-on:check="checkedAll"
              v-on:edit="edit(row)"
              :key="index"
              v-on:remove="remove(row)">
          </TableRow>

          </tbody>
        </table>
      </div>
    </template>

  </Card>

</template>

<script>
  import TableRow from './TableRow'
  import Card from '../../ui/card/Card'

  export default {
    name:       'Table',
    components: {TableRow, Card},
    props:      {},

    computed: {

      table () {
        return this.$store.getters.pageTable
      },

      tableRows () {
        if (this.table) {
          const table        = this.table.body,
                displayTable = [],
                header       = this.table.header,
                flatHeader   = header.map(item => item.key)

          table.forEach((item) => {
            const keys    = Object.keys(item)
            const newItem = []
            keys.forEach((key, i) => {
              if (flatHeader.includes(key)) {
                newItem.push({val: item[key], key: key})
              }
            })
            displayTable.push(newItem)

          })

          //const sortedData = displayTable.sort((a, b) => flatHeader.indexOf(a.key) - flatHeader.indexOf(b.key))
          //const sortedData = displayTable.sort((a, b) => flatHeader.indexOf(a.key) - flatHeader.indexOf(b.key))
          //

          return displayTable

        }
      }
    },

    data () {
      return {
        searchInput: null,
        checked:     false
      }
    },

    methods: {

      edit (event) {
        this.$emit('edit', event)
      },

      remove (event) {
        this.$emit('remove', event)
      },

      notCheckedAll () {
        this.checked = false
      },

      checkedAll () {
        this.checked = !this.checked
      },

      // Очистка поля поиска
      clearSearchVal () {
        this.table.searchInput = null
      }

    }
  }
</script>
