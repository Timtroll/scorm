<template>
  <tr>
    <td class="pos-table-expand">

      <!--remove Row-->
      <a class="uk-icon-link uk-link-muted uk-display-inline-block"
         style="width: 16px"
         @click.prevent="toggleEllipsis">
        <img height="16"
             v-if="ellipsis"
             src="/img/icons/icon_arrow__down.svg"
             uk-svg
             width="16">
        <img height="16"
             v-else
             src="/img/icons/icon_arrow__up.svg"
             uk-svg
             width="16"></a>
    </td>
    <!--data-->
    <td v-for="(item, index) in rowData"
        class="pos-table-row cursor-pointer"
        :class="{'ellipsis' : ellipsis}"
        @click="edit(fullData)">
      <div v-text="item.val"></div>
    </td>

    <!--check current-->
    <td class="pos-table-checkbox uk-text-right uk-text-nowrap">

      <!--edit Row-->
      <a class="uk-icon-link uk-margin-small-right uk-display-inline-block"
         @click.prevent="edit(fullData)">
        <img src="/img/icons/icon__edit.svg"
             width="16"
             height="16"
             uk-svg></a>

      <!--remove Row-->
      <a class="uk-icon-link uk-link-muted uk-display-inline-block"
         @click.prevent="remove(rowData)">
        <img height="16"
             src="/img/icons/icon__trash.svg"
             uk-svg
             width="16"></a>

      <!--select Row-->
      <input type="checkbox"
             v-if="massEdit"
             @change="notCheckedAll"
             v-model="checkedRow"
             class="pos-checkbox-switch xsmall uk-margin-small-left">
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

      fullData: {
        required: true
      },

      massEdit: {
        type:    Number,
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

    computed: {

      // Поле можно удалять
      removable () {
        return this.rowData.removable !== 1;
      },

      editPanel_api () {
        return this.$store.getters.editPanel_api
      },

      table_api () {
        return this.$store.getters.table_api
      },

      cardRightState () {
        return this.$store.getters.cardRightState
      },

      inputComponents () {
        return this.$store.getters.inputComponents.length > 0
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

      edit (item) {

        this.$store.dispatch(this.editPanel_api.get, item.id)
        this.$store.commit('card_right_show', !this.cardRightState)

      },

      remove () {

        this.$store.dispatch('removeTableRow', this.fullData.id)
      }

    }
  }
</script>
