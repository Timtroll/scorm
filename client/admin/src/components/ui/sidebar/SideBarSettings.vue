<template>
  <ul class="pos-sidebar--nav">
    <router-link tag="li"
                 :to="{name: 'Settings'}"
                 active-class="uk-active"
                 exact>
      <a>
        <icon-setting :spin="true"></icon-setting>
      </a>
    </router-link>
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
    }
  }
</script>
