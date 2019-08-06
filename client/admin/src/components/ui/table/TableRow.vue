<template>

  <tr>
    <!--data-->
    <td v-for="item in rowData"
        class="pos-table-row cursor-pointer"
        :class="{'ellipsis' : ellipsis}"
        @click="toggleEllipsis"
        @dblclick="edit(rowData)">
      <div v-text="item.value"></div>
    </td>

    <!--check current-->
    <td class="pos-table-checkbox uk-text-right uk-text-nowrap">

      <!--edit Row-->
      <a class="uk-icon-link uk-margin-small-right uk-display-inline-block"
         @click.prevent="edit(rowData)">
        <img src="/img/icons/icon__edit.svg"
             width="16"
             height="16"
             uk-svg></a>

      <!--remove Row-->
      <a class="uk-icon-link uk-link-muted uk-margin-small-right uk-display-inline-block"
         @click.prevent="remove(rowData)">
        <img height="16"
             src="/img/icons/icon__trash.svg"
             uk-svg
             width="16"></a>

      <!--select Row-->
      <input type="checkbox"
             @change="notCheckedAll"
             v-model="checkedRow"
             class="pos-checkbox-switch xsmall">

    </td>
  </tr>

</template>

<script>
  export default {
    name: 'TableRow',

    props: {

      checkedAll: {
        type:    Boolean,
        default: false
      },

      rowData: {
        type:     Array,
        required: true
      }

    },

    watch: {

      checkedAll () {
        this.checkedRow = this.checkedAll
      }
    },

    data () {
      return {
        ellipsis:   true,
        checkedRow: false
      }
    },

    methods: {

      toggleEllipsis () {
        this.ellipsis = !this.ellipsis
      },

      notCheckedAll () {
        if (this.checkedAll) {
          this.$emit('check')

        }
        this.checkedRow = true
      },

      edit (event) {
        this.$emit('edit', event)
      },

      remove (event) {
        this.$emit('remove', event)
      }

    }
  }
</script>
