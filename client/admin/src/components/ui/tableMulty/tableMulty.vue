<template>
  <div class="uk-overflow-auto uk-height-1-1 uk-position-relative">
    <table class="uk-table pos-table uk-table-striped uk-table-hover uk-table-divider uk-table-small  uk-table-middle"
           :class="{'no-border': !borders}">

      <!--header-->
      <thead class="pos-table-header">
      <tr>
        <!--expand Row-->
        <th class="pos-table-expand">
          <span style="width: 16px">
            <img src="/img/icons/icon__expand.svg"
                 width="16"
                 height="16"
                 uk-svg>
          </span>
        </th>

        <!--header rows data-->
        <th v-for="item in header"
            v-text="item"></th>
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

      <TableRow :row-data="row"
                :checked-all="checked"
                v-for="(row, index) in data"
                v-on:check="checkedAll"
                v-on:edit="edit(row)"
                :key="index"
                v-on:remove="remove(row)">
      </TableRow>

      </tbody>
    </table>
  </div>
</template>

<script>
  import TableRow from './TableMultyRow'

  export default {
    name:       'Table',
    components: {TableRow},
    props:      {

      settings: {
        type: Object
      },

      borders: {
        type:    Boolean,
        default: true
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
      }

    }
  }
</script>
