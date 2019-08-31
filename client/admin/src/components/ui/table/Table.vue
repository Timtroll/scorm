<template>
  <Card :header="true"
        :header-large="false"
        :header-bgr-default="true"
        :header-left="true"
        :body-padding="false"
        :header-small="true"

        :header-padding-none="true"
        :body-right-header-title="card.bodyRightTitle"
        :body-right-show="tableRowDetail.open">
    <!--:loader="notEmptyTable"-->

    <template #headerLeft>
      <div class="uk-flex">

        <!--Add Row-->
        <button type="button"
                class="uk-button uk-button-success pos-border-radius-none pos-border-none"
                @click.prevent="add_row">
          <img src="/img/icons/icon__plus.svg"
               width="16"
               height="16"
               uk-svg>
          <span class="uk-margin-small-left uk-visible@m"
                v-text="$t('actions.add')"></span>
        </button>

        <!--Remove Row-->
        <button class="uk-button-danger pos-border-radius-none pos-border-none"
                v-if="massEdit">
          <img src="/img/icons/icon__trash.svg"
               uk-svg
               width="10"
               height="10">
          <span class="uk-margin-small-left uk-visible@s"
                v-text="$t('actions.remove')"></span>
        </button>

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
        <div class="uk-form-icon">
          <img src="/img/icons/icon__search.svg"
               width="14"
               height="14"
               uk-svg>
        </div>
        <input type="text"
               v-model="searchInput"
               @keyup.esc="clearSearchVal"
               placeholder="Поиск"
               class="uk-input pos-border-radius-none pos-border-none">
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
            <th class="pos-table-expand uk-table-shrink uk-text-center">
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
              :full-data="filterSearch[index]"
              :checked-all="checked"
              v-for="(row, index) in tableRows"
              v-on:check="checkedAll"
              v-on:edit-row="edit(filterSearch[index])"
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
            :parent="libId"
            :folder="0"
            :add="card.add"
            :labels="card.bodyRightTitle"
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
          bodyRightItem:  null,
          add:            false,
          folder:         0
        },

        editRequired: {
          name:        true,
          placeholder: true,
          label:       true,
          type:        true
        },

        addTpl: {
          folder:      0,
          lib_id:      +this.libId,
          label:       '',
          name:        '',
          type:        '',
          placeholder: '',
          editable:    1,
          mask:        '',
          readOnly:    0,
          required:    1,
          value:       '',
          selected:    []
        }

      }
    },

    computed: {

      notEmptyTable () {
        return (this.table && Object.keys(this.table).length === 0) ? 'error' : 'success'
      },

      libId () {
        if (this.table && this.table.body[0] && this.table.body[0].lib_id) {
          return +this.table.body[0].lib_id
        } else {
          return +this.$store.getters.pageTableCurrentId
        }
      },

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
        if (this.filterSearch) {
          const table        = this.filterSearch,
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

          return displayTable
        }
      },

      //tableRows () {
      //  if (this.table) {
      //    const table        = this.table.body,
      //          displayTable = [],
      //          header       = this.table.header,
      //          flatHeader   = header.map(item => item.key)
      //
      //    table.forEach((item) => {
      //      //const keys    = Object.keys(item)
      //      const newItem = []
      //
      //      flatHeader.forEach((headItem, i) => {
      //        if (item.hasOwnProperty(headItem)) {
      //          newItem.push({val: item[headItem], key: headItem})
      //        }
      //      })
      //
      //      displayTable.push(newItem)
      //    })
      //
      //    return displayTable
      //  }
      //},

      // Поиск по полю label && keywords
      filterSearch () {

        if (this.table.body) {

          const tableBody = this.table.body

          return tableBody.filter(item => {
            return !this.searchInput
              || item.label.toLowerCase().indexOf(this.searchInput.toLowerCase()) > -1
              || item.keywords.toLowerCase().indexOf(this.searchInput.toLowerCase()) > -1
          })
        }
      }

    },

    methods: {

      add_row () {
        this.card.bodyRightItem  = this.addTpl
        this.card.add            = true
        this.card.bodyRightTitle = this.$t('actions.addRow')
        this.toggleRightPanel()
        this.$store.commit('cms_row_success')
      },

      edit (event) {
        this.card.bodyRightTitle = null
        this.card.add            = false
        this.card.bodyRightItem  = event
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
        this.searchInput = null
      },

      toggleRightPanel () {
        this.$store.commit('cms_table_row_show', !this.tableRowDetail.open)
      }

    }
  }
</script>
