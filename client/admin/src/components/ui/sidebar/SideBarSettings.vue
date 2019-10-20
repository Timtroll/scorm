<template>
  <ul class="pos-sidebar--nav">

    <li>
      <a>
        <icon-setting :spin="true"></icon-setting>
      </a>
      <div uk-dropdown="mode: click; pos: right-bottom;  animation: uk-animation-slide-right-small; duration: 300">
        <ul class="uk-nav uk-dropdown-nav pos-sidebar-dropdown-nav">
          <li class="uk-nav-header">Header</li>
          <li class="uk-nav-divider"></li>
          <li v-for="(item, index) in menuSettings"
              :key="index"
              :class="{'uk-active' : activeClass(item.name)}">
            <router-link exact
                         class="pos-sidebar-dropdown-nav--link"
                         :to="item.path"
                         :title="item.meta.breadcrumb">
              <img :uk-img="'data-src:' + item.meta.icon"
                   uk-svg
                   class="pos-sidebar-dropdown-nav--icon"
                   width="18"
                   height="18">
              <span class="pos-sidebar-dropdown-nav--label"
                    v-text="item.meta.breadcrumb"></span>
            </router-link>
          </li>
        </ul>
      </div>

    </li>

  </ul>
</template>
<script>

  export default {

    name: 'SideBarSettings',

    components: {
      IconSetting: () => import(/* webpackChunkName: "IconSetting" */ '../icons/IconSetting')
    },

    props: {
      size:  {
        type:    Number,
        default: 24
      },
      width: {
        type:    Number,
        default: 1
      }
    },

    computed: {
      menuSettings () {
        return this.$router.options.routes
                   .filter(item => item.sideSettingsMenuParent)[0]
          .children
          .filter(item => item.showInSettings)
      }
    },
    methods:  {
      activeClass (name) {return this.$route.name === name || this.$route.meta.parentName === name }
    }
  }
</script>
