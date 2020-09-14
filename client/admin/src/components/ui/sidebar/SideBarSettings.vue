<template>
  <ul class="pos-sidebar--nav">

    <li>
      <a>
        <icon-setting :spin="true"/>
      </a>
      <div :uk-dropdown="dropdownOptions"
           ref="settings">
        <ul class="uk-nav uk-dropdown-nav pos-sidebar-dropdown-nav">

          <li class="uk-nav-header"
              v-text="$t('settings.navLabel')"/>

          <li class="uk-nav-divider"/>

          <li v-for="(item, index) in menuSettings"
              :key="index"
              :class="{'uk-active' : activeClass(item.name)}"
              @click.prevent="close">
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
                    v-text="item.meta.breadcrumb"/>
            </router-link>
          </li>

          <li class="uk-nav-divider"/>

          <li>
            <a @click.prevent="goToGraphUrl">
              <img :uk-img="'data-src:img/icons/pos_none.svg'"
                   uk-svg
                   class="pos-sidebar-dropdown-nav--icon"
                   width="18"
                   height="18">
              <span class="pos-sidebar-dropdown-nav--label"
                    v-text="'граф EAV'"/>
            </a>
          </li>

        </ul>
      </div>

    </li>

  </ul>
</template>
<script>

import {dropHide} from '@/store/methods'

export default {

  name: 'SideBarSettings',

  components: {
    IconSetting: () => import(/* webpackChunkName: "IconSetting" */ '../icons/IconSetting')
  },

  props: {
    size:       {
      type:    Number,
      default: 24
    },
    width:      {
      type:    Number,
      default: 1
    },
    innerWidth: {
      type: Number
    }
  },

  computed: {
    graphUrl () {
      return window.location.origin + '/manage_eav'
    },

    dropdownOptions () {

      let position = 'right-bottom'

      if (this.innerWidth <= 768) {
        position = 'mode: click; pos: top-right;  animation: uk-animation-slide-right-small; duration: 300'
      }
      else {
        position = 'mode: click; pos: right-bottom;  animation: uk-animation-slide-right-small; duration: 300'
      }
      return position
    },

    menuSettings () {
      return this.$router.options.routes
                 .filter(item => item.sideSettingsMenuParent)[0]
        .children
        .filter(item => item.showInSettings)
    }
  },
  methods:  {
    goToGraphUrl () {
      //console.log(window.location)
      //window.open(this.graphUrl, '_blank')
    },

    activeClass (name) {return this.$route.name === name || this.$route.meta.parentName === name },

    close () {
      dropHide(this.$refs.settings)
    }
  }
}
</script>
