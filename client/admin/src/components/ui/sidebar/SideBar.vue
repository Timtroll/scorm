<template>
  <div class="pos-sidebar uk-light"
       id="sidebar">
    <div class="pos-sidebar-top uk-visible@m">
      <router-link :to="{name: 'Main'}">
        <img uk-img="data-src:/img/logo__bw.svg"
             class="pos-sidebar-logo"
             uk-svg>
      </router-link>
    </div>
    <div class="pos-sidebar-middle uk-light">
      <ul class="pos-sidebar--nav">
        <li v-for="(item, index) in menu"
            :key="index"
            :class="{'uk-active' : activeClass(item.name)}">
          <router-link uk-tooltip
                       exact
                       :to="item.path"
                       :pos="tooltipPosition"
                       :title="item.meta.breadcrumb">
            <img :uk-img="'data-src:' + item.meta.icon"
                 uk-svg
                 :alt="''"
                 width="24"
                 height="24">
          </router-link>
        </li>
      </ul>
    </div>
    <div class="pos-sidebar-bottom">

      <!--Settings-->
      <SideBarUserMenu :size="30"
                       :inner-width="width"
                       :width="1">
      </SideBarUserMenu>
    </div>
  </div>
</template>
<script>

  export default {

    name: 'SideBar',

    components: {
      SideBarUserMenu: () => import(/* webpackChunkName: "SideBarSettings" */ './SideBarSettings.vue')
    },

    // Отслеживание изменния ширины экрана
    mounted () {
      window.addEventListener('resize', this.handleResize)
    },

    beforeDestroy: function () {
      window.removeEventListener('resize', this.handleResize)
    },

    data () {

      return {
        width: window.innerWidth
      }

    },

    computed: {

      tooltipPosition () {
        let position = 'right'
        if (this.width <= 768) {
          position = 'top'
        } else {
          position = 'right'
        }
        return position
      },

      // side menu
      menu () {
        return this.$router.options.routes
                   .filter(item => item.sideMenuParent)[0]
          .children
          .filter(item => item.showInSideBar)
      }

    },

    //
    methods: {
      activeClass (name) {return this.$route.name === name || this.$route.meta.parentName === name },

      handleResize (event) {
        setTimeout(() => { this.width = window.innerWidth}, 300)
      }
    }
  }
</script>
