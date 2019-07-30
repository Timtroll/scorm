<template>
  <div>
    <ul class="pos-side-nav">
      <li v-for="item in nav"
          :key="item.id">
        <NavTreeItem :nav-item="item"></NavTreeItem>
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
      nav: {
        type: Array
      }
    }
  }
</script>
