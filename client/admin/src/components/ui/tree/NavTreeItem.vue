<template>
  <div>

    <!--current nav item-->
    <div class="pos-side-nav-item">

      <div class="pos-side-nav-item__icon"
           @click="toggleChildren"
           v-if="navItem.children && navItem.children.length > 0">
        <img src="/img/icons/icon__minus.svg"
             uk-svg
             v-if="opened">
        <img src="/img/icons/icon__plus.svg"
             uk-svg
             v-else>
      </div>
      <div class="pos-side-nav-item__no-icon"
           v-else>
      </div>
      <a class="pos-side-nav-item__label"
         @click.prevent="click(navItem)"
         :uk-tooltip="'pos: top-left; delay: 1000; title:' + navItem.label"
         v-text="navItem.label"></a>
    </div>

    <!--children nav items-->
    <NavTree v-if="navItem.children && navItem.children.length > 0 && opened"
             :nav="navItem.children">
    </NavTree>

  </div>
</template>

<script>

  export default {

    name: 'NavTreeItem',

    components: {
      'NavTree': () => import('./NavTree')
    },
    props:      {

      navItem: {
        type: Object
      }
    },

    data () {
      return {
        opened: false
      }
    },

    methods: {

      toggleChildren () {
        this.opened = !this.opened
      },

      click (item) {
        this.$store.commit('setTableData', item)
        this.$emit('click')
      }
    }
  }
</script>
