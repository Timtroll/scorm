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
    <td v-for="(item, index) in updateData"
        class="pos-table-row cursor-pointer"
        :class="{'ellipsis' : ellipsis}"
        @click="edit(updateData[index].inline, item.key)">

      <label class="uk-text-center uk-display-block cursor-pointer"
             v-if="updateData[index].inline === 1">
        <input type="checkbox"
               v-model="updateData[index].val"
               class="pos-checkbox-switch xsmall">
      </label>

      <div v-else
           v-text="item.val"></div>
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

      rowData () {
        this.updateData = {...this.rowData}
      },

      checkedAll () {
        this.checkedRow = this.checkedAll
      }
    },

    async mounted () {

      //const input = this.rowData
      //const data      = await function () {
      //  return input
      //}
      this.updateData = {...this.rowData}

    },

    computed: {

      // Поле можно удалять
      removable () {
        return this.rowData.removable !== 1
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
        checkedRow: false,
        updateData: []

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

      edit (inline = 0, key) {

        if (inline === 1) {

          const data = {...this.fullData}

          const sendData = {
            parent: data.parent,
            data:   {
              id:    data.id,
              [key]: '' + Number(!data[key])
            }
          }

          this.$store.dispatch(this.table_api.saveField, sendData)
        } else {
          this.$store.dispatch(this.editPanel_api.get, this.fullData.id)
        }

      },

      remove () {

        //this.$store.dispatch('removeTableRow', this.fullData.id)
      }

    }
  }
</script>
