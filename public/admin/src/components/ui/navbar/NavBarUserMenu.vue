<template>
  <div class="uk-navbar-dropdown uk-dropdown-small"
       uk-dropdown="mode: click; offset: 10; pos: bottom-right; animation: uk-animation-slide-right-medium">
    <ul class="uk-nav uk-navbar-dropdown-nav">
      <router-link tag="li"
                   :to="{name: 'Profile'}"
                   active-class="uk-active"
                   exact>
        <a>
          <img src="../../../../public/img/icons/user_profile.svg"
               uk-svg
               width="16"
               height="16" class="uk-margin-small-right">
          Профиль пользователя</a>
      </router-link>
      <li>
        <a @click.prevent="signOut">
          <img src="../../../../public/img/icons/user_logout.svg"
               uk-svg
               width="16"
               height="16"
               class="uk-margin-small-right">
          Выйти
        </a>
      </li>
    </ul>
  </div>
</template>
<script>
  import UIkit from 'uikit/dist/js/uikit'
  import IconSetting from '../icons/IconSetting'

  export default {

    name:       'NavBarUserMenu',
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

    methods: {

      signOut () {

        UIkit.modal.confirm('Выйти из системы!', {

          labels: {ok: 'Выйти', cancel: 'Остаться в системе'}
        }).then(() => {

          this.$store.commit('setAuth', true)
          sessionStorage.setItem('auth', 'false')
          this.$router.push({name: 'Login'})
        }, () => {

          console.log('Rejected.')
        })

      }
    }
  }
</script>
