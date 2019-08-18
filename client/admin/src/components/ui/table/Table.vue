<template>
  <Card :header="true"
        :header-large="false"
        :header-bgr-default="true"
        :header-left="true"
        :body-padding="false"
        :body-right-header-title="card.bodyRightTitle"
        :body-right-show="tableRowDetail.open">

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
        <div v-if="massEdit">
          <button class="uk-button-danger uk-button uk-button-small">
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
               class="uk-table pos-table uk-table-striped uk-table-hover uk-table-divider uk-table-small uk-table-middle">

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
            <th class="uk-text-right pos-table-checkbox uk-text-nowrap">
              <!--edit Row-->
              <div class="uk-margin-small-right uk-display-inline-block">
                <img src="/img/icons/icon__edit.svg"
                     width="16"
                     height="16"
                     uk-svg></div>

              <!--remove Row-->
              <div class="uk-display-inline-block">
                <img height="16"
                     src="/img/icons/icon__trash.svg"
                     uk-svg
                     width="16"></div>
              <div v-if="massEdit"
                   class="uk-margin-small-left">

                <input type="checkbox"
                       v-model="checked"
                       @click="checkedAll"
                       class="pos-checkbox-switch xsmall uk-display-inline-block">
              </div>
            </th>
          </tr>
          </thead>
          <tbody>

          <TableRow
              :row-data="row"
              :mass-edit="massEdit"
              :full-data="table.body[index]"
              :checked-all="checked"
              v-for="(row, index) in tableRows"
              v-on:check="checkedAll"
              v-on:edit-row="edit(table.body[index])"
              :key="index"
              v-on:remove="remove(row)">
          </TableRow>

          </tbody>
        </table>
      </div>
    </template>

    <!--bodyRight-->
    <template #bodyRight>
      <List :data="JSON.parse(JSON.stringify(card.bodyRightItem))"
            :required="editRequired"
            v-on:title="card.bodyRightTitle = $event"
            v-on:close="toggleRightPanel"></List>
    </template>

  </Card>

</template>

<script>
  import TableRow from './TableRow'
  import Card from '../../ui/card/Card'
  import List from '../../ui/list/List'

  export default {
    name:       'Table',
    components: {TableRow, Card, List},
    props:      {},

    data () {
      return {

        searchInput: null,
        checked:     false,

        card: {
          bodyRightShow:  true,
          bodyRightTitle: null,
          bodyRightItem:  null
        },

        editRequired: {
          name:        true,
          placeholder: true,
          label:       true,
          type:        true
        }

      }
    },

    computed: {

      table () {
        return this.$store.getters.pageTable
      },

      massEdit () {
        if (this.table && this.table.settings && this.table.settings.massEdit) {
          return this.table.settings.massEdit
        } else {
          return 0
        }
      },

      tableRowDetail () {
        return this.$store.getters.pageTableRow
      },

      tableRows () {
        if (this.table) {
          const table        = this.table.body,
                displayTable = [],
                header       = this.table.header,
                flatHeader   = header.map(item => item.key)

          table.forEach((item) => {
            //const keys    = Object.keys(item)
            const newItem = []

            flatHeader.forEach((headItem, i) => {
              if (item.hasOwnProperty(headItem)) {
                newItem.push({val: item[headItem], key: headItem})
              }
            })

            displayTable.push(newItem)
          })

          //table.forEach((item) => {
          //  const keys    = Object.keys(item)
          //  const newItem = []
          //
          //  keys.forEach((key, i) => {
          //    if (flatHeader.includes(key)) {
          //      newItem.push({val: item[key], key: key})
          //    }
          //  })
          //
          //  displayTable.push(newItem)
          //})

          return displayTable

        }
      }

    },

    methods: {

      edit (event) {
        this.card.bodyRightItem = event
        this.$store.commit('cms_row_success')
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
      },

      toggleRightPanel () {
        this.$store.commit('cms_table_row_show', !this.tableRowDetail.open)
      }

    }
  }
</script>
