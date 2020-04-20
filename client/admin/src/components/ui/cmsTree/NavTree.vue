<template>
  <div class="">
    <ul class="pos-side-nav">
      <li v-for="item in nav"
          :key="item.id">
        <NavTreeItem :nav-item="item"
                     :remove-item="remove"
                     :editable="editable"
                     :add-children-item="addChildren"></NavTreeItem>
      </li>
    </ul>
  </div>
</template>

<script>
  import NavTreeItem from './NavTreeItem'

  export default {

    name: 'NavTree',

    components: {NavTreeItem},

    props: {

      addChildren: {
        type:    Boolean,
        default: true
      },

      editable: {
        type:    Boolean,
        default: true
      },
      remove:   {
        type:    Boolean,
        default: true
      },
      nav:      {
        type: Array
      }
    }

  }
</script>
