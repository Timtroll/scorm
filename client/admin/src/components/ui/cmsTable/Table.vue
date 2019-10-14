<template>
  <Card :header="true"
        :header-large="false"
        :header-bgr-default="true"
        :header-left="true"
        :header-right="true"
        :body-padding="false"
        :header-small="true"
        :header-padding-none="true"
        :loader="loader">
    <!--:loader="notEmptyTable"-->

    <!--actions add / mass remove-->
    <template #headerLeft>
      <div class="uk-flex"
           v-if="header">

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
        <button class="uk-button-default pos-border-radius-none pos-border-none uk-flex uk-flex-middle"
                v-if="massEdit && tableNotEmpty"
                disabled>
          <img src="/img/icons/icon__trash.svg"
               uk-svg
               width="12"
               height="12">
          <span class="uk-margin-small-left uk-visible@s"
                v-text="$t('actions.remove')"></span>
        </button>

      </div>

    </template>

    <!--Показать колонки-->
    <template #headerRight>
      <div class="uk-flex-column uk-flex pos-border-left"
           v-if="tableNotEmpty">
        <button class="uk-button uk-button-default pos-border-radius-none pos-border-none"
                type="button">
          <img src="/img/icons/icon__input_table_row.svg"
               width="20"
               height="20"
               uk-svg></button>

        <div uk-dropdown="mode: click; offset: 0; pos: bottom-right; animation: uk-animation-slide-right-medium">
          <ul class="uk-nav uk-dropdown-nav">

            <li class="uk-nav-header"
                v-text="$t('table.headerItems')"></li>
            <li class="uk-nav-divider"></li>

            <li v-for="(item, index) in header">
              <label class="uk-grid-small"
                     uk-grid>
                <span class="uk-width-expand uk-text-truncate"
                      v-text="item.label"></span>
                <input class="pos-checkbox-switch xsmall"
                       v-model.number="item.show"
                       :true-value="1"
                       :false-value="0"
                       @change="updateVisibleColumns(header)"
                       type="checkbox">
              </label>
            </li>
          </ul>
        </div>

      </div>

    </template>

    <!--search-->
    <template #header>

      <!--table searchInput-->
      <div class="uk-position-relative uk-width-medium uk-margin-auto-left pos-border-left"
           v-if="tableNotEmpty">
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

        <table v-if="tableNotEmpty"
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
            <th v-for="item in tableHeader"
                v-text="item.label"
                :class="{'inline': item.inline === 1}"></th>

            <th class="uk-text-right pos-table-checkbox uk-text-nowrap"
                v-if="editable || removable || massEdit">

              <!--edit Row-->
              <div class="uk-margin-small-right uk-display-inline-block"
                   v-if="editable">
                <img src="/img/icons/icon__edit.svg"
                     width="16"
                     height="16"
                     uk-svg></div>

              <!--remove Row-->
              <div class="uk-display-inline-block"
                   v-if="removable">
                <img height="16"
                     src="/img/icons/icon__trash.svg"
                     uk-svg
                     width="16">
              </div>

              <div v-if="massEdit"
                   class="uk-margin-small-left">

                <input type="checkbox"
                       v-model="checked"
                       @click="checkedAll"
                       class="pos-checkbox-switch danger xsmall uk-display-inline-block">
              </div>
            </th>
          </tr>
          </thead>

          <tbody>
          <TableRow
              :row-data="row"
              :mass-edit="massEdit"
              :editable="table.settings.editable"
              :removable="table.settings.removable"
              :full-data="filterSearch[index]"
              :checked-all="checked"
              v-for="(row, index) in tableRows"
              v-on:check="checkedAll"
              :key="index">
          </TableRow>
          </tbody>

        </table>

        <!--// empty Table-->
        <div class="uk-position-cover uk-flex uk-flex-center uk-flex-middle uk-text-muted"
             v-else>
          <div class="uk-flex-center uk-flex uk-flex-column">

            <img src="/img/icons/icon__empty.svg"
                 class="uk-margin-auto"
                 width="60"
                 height="60"
                 uk-svg>

            <button type="button"
                    class="uk-button uk-button-default uk-margin-top"
                    @click.prevent="add_row">
              <img src="/img/icons/icon__plus.svg"
                   width="16"
                   height="16"
                   uk-svg>
              <span class="uk-margin-small-left"
                    v-text="$t('actions.add')"></span>
            </button>
          </div>
        </div>
      </div>
    </template>

  </Card>

</template>

<script>

  import {clone} from '../../../store/methods'

  export default {

    name: 'Table',

    components: {
      TableRow: () => import(/* webpackChunkName: "TableRow" */ './TableRow'),
      Card:     () => import(/* webpackChunkName: "Card" */ '../../ui/card/Card')
    },

    data () {
      return {

        tableId: null,
        //table_api: null,

        searchInput: null,
        checked:     false,

        card: {
          add:    false,
          folder: 0
        },

        header: [],

        editRequired: {
          name:        true,
          placeholder: true,
          label:       true,
          type:        true
        }

      }
    },

    watch: {

      table () {

        if (this.table) {
          const headerLocal = localStorage.getItem(this.pageComponent + '_header_' + this.tableId)

          if (headerLocal) {
            this.header = clone(headerLocal)
          } else {
            this.header = clone(this.protoLeaf)
          }
        }
      }

    },

    async mounted () {

      this.tableId = this.$route.params.id
      //this.table_api = await this.$store.getters.table_api

      console.log(this.table_api)

      if (this.notEmptyTable === 'error') {
        await this.$store.commit('card_right_show', false)
        await this.$store.commit('tree_active', this.tableId)
        //this.$store.dispatch(this.table_api.get, this.tableId)
      }

    },

    beforeDestroy () {
      this.$store.commit('editPanel_show', false)
      this.$store.commit('tree_active', null)
      this.$store.commit('set_editPanel_proto', [])
      this.$store.commit('set_tree_proto', [])

      // выгрузка Vuex модуля settings
      //this.$store.unregisterModule('settings')
    },

    computed: {

      pageComponent () {
        return this.$route.name
      },

      tableNotEmpty () {
        if (this.tableRows) {
          return this.tableRows.length > 0
        }
      },

      table_api () {

        const api = this.$store.getters.table_api
        console.log('api', api)

        return this.$store.getters.table_api
      },

      loader () {
        return this.$store.getters.table_status
      },

      protoLeaf () {
        return this.$store.getters.editPanel_proto
      },

      notEmptyTable () {
        return (this.table && Object.keys(this.table).length === 0) ? 'error' : 'success'
      },

      table () {
        return this.$store.getters.table_items
      },

      massEdit () {

        if (this.table && this.table.settings && this.table.settings.massEdit) {
          return this.table.settings.massEdit
        } else {
          return 0
        }
      },

      removable () {

        if (this.table && this.table.settings && this.table.settings.removable) {
          return this.table.settings.removable
        } else {
          return 0
        }
      },

      editable () {

        if (this.table && this.table.settings && this.table.settings.editable) {
          return this.table.settings.editable
        } else {
          return 0
        }
      },

      tableRowDetail () {
        return this.$store.getters.pageTableRow
      },

      // Шапка таблицы
      tableHeader () {
        if (this.header) {
          return this.header.filter(item => item.show === 1)
        }
      },

      //Тело таблицы
      tableRows () {
        if (this.filterSearch) {
          const table        = this.filterSearch,
                displayTable = [],
                flatHeader   = this.tableHeader.map(item => item.name)

          table.forEach((item) => {
            const newItem = []

            flatHeader.forEach((headItem, i) => {

              if (item.hasOwnProperty(headItem)) {
                newItem.push({
                  val:    item[headItem],
                  key:    headItem,
                  inline: this.tableHeader[i].inline // if header inline = 1
                })
              }
            })

            displayTable.push(newItem)
          })

          this.$store.commit('table_status_success')
          return displayTable
        }
      },

      // Поиск по полю label && keywords
      filterSearch () {

        if (this.table.body) {

          const tableBody = clone(this.table.body)

          let table = tableBody

          if (this.table.settings.sort) {
            const sortBy    = this.table.settings.sort.name,
                  sortOrder = this.table.settings.sort.order

            table = tableBody.sort(this.compareValues(sortBy, sortOrder))
          }

          return table.filter(item => {
            return !this.searchInput
              || item.name.toLowerCase().indexOf(this.searchInput.toLowerCase()) > -1
              || item.label.toLowerCase().indexOf(this.searchInput.toLowerCase()) > -1
          })
        }
      }

    },

    methods: {

      // сохранение настроек видимости колонок таблицы
      updateVisibleColumns (item) {
        localStorage.setItem(
          this.pageComponent + '_header_' + this.tableId, JSON.stringify(item)
        )

      },

      async add_row () {

        const proto = await clone(this.$store.getters.editPanel_proto)

        await proto.forEach(item => {
          if (item.name === 'parent') {
            item.value = this.tableId
          }
        })

        await this.$store.commit('editPanel_status_request')
        await this.$store.commit('editPanel_add', true)
        await this.$store.commit('editPanel_folder', false)
        await this.$store.commit('card_right_show', true)
        await this.$store.commit('editPanel_data', [])

        await this.$store.commit('editPanel_data', proto) // запись данных во VUEX
        await this.$store.commit('editPanel_status_success') // статус - успех

      },

      // отмена выделения всех строк
      notCheckedAll () {
        this.checked = false
      },

      // выделить все строки
      checkedAll () {
        this.checked = !this.checked
      },

      // Очистка поля поиска
      clearSearchVal () {
        this.searchInput = null
      },

      // sort
      //sortBy (array, sortBy = 'name', sortOrder = 'asc') {
      //  array.sort(this.compareValues(sortBy, sortOrder))
      //},

      // sort Function
      compareValues (key, order = 'asc') {
        return function (a, b) {
          if (!a.hasOwnProperty(key) || !b.hasOwnProperty(key)) {
            // свойства нет ни в одном из объектов
            return 0
          }

          const varA = (typeof a[key] === 'string') ?
            a[key].toUpperCase() : a[key]
          const varB = (typeof b[key] === 'string') ?
            b[key].toUpperCase() : b[key]

          let comparison = 0
          if (varA > varB) {
            comparison = 1
          } else if (varA < varB) {
            comparison = -1
          }
          return (
            (order === 'desc') ? (comparison * -1) : comparison
          )
        }
      }

    }
  }
</script>
