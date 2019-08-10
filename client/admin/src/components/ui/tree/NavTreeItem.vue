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
         :class="{'uk-active': navActiveId === navItem.id}"
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

    computed: {

      navActiveId () {
        return this.$store.state.cms.cms.activeId
      }
    },

    methods: {

      toggleChildren () {
        this.opened = !this.opened
      },

      click (item) {
        if(this.navActiveId !== this.navItem.id){
          this.$store.commit('tree_active', item.id)
          this.$store.commit('cms_table', item.table)
          this.$emit('close')
          this.$router.push({
            name:   'SettingItem',
            params: {
              id:   item.id,
              item: item
            }
          })
        }

      }
    }
  }
</script>
