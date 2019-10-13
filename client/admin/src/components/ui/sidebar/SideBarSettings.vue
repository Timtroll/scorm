<template>
  <ul class="pos-sidebar--nav">

    <li :class="{'uk-active' : activeClass('Users')}">
      <router-link :to="{name: 'Users'}" exact>
        <img src="img/icons/sidebar_users.svg"
             uk-svg
             width="24"
             height="24">
      </router-link>
    </li>

    <li :class="{'uk-active' : activeClass('Groups')}">
      <router-link :to="{name: 'Groups'}" exact>
        <img src="img/icons/sidebar_roles.svg"
             uk-svg
             width="24"
             height="24">
      </router-link>
    </li>

    <li :class="{'uk-active' : activeClass('Settings')}">
      <router-link :to="{name: 'Settings'}" exact>
        <icon-setting :spin="true"></icon-setting>
      </router-link>
    </li>

  </ul>
</template>
<script>
  import IconSetting from '../icons/IconSetting'

  export default {

    name:       'SideBarSettings',
    components: {IconSetting},
    props:      {
      size:  {
        type:    Number,
        default: 24
      },
      width: {
        type:    Number,
        default: 1
      }
    },
    methods:    {
      activeClass (name) {return this.$route.name === name || this.$route.meta.parentName === name }
    }
  }
</script>
