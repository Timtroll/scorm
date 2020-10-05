<template>
  <div class="uk-navbar-dropdown uk-dropdown-small"
       uk-dropdown="mode: click; offset: 10; pos: bottom-right; animation: uk-animation-slide-right-medium">

    <div class="uk-grid-small"
         uk-grid>

      <div class="uk-width-auto">
        <canvas width="60"
                height="60"
                class="uk-border-circle uk-background-warning"></canvas>
      </div>
      <div class="uk-width-expand pos-navbar-user-info">
        <div>Иванов</div>
        <div>Сергей</div>
        <div>Николаевич</div>
        <div class="uk-text-muted"><small>Преподаватель</small></div>
      </div>

    </div>

    <hr class="uk-divider-small"/>

    <ul class="uk-nav uk-navbar-dropdown-nav">
      <router-link tag="li"
                   :to="{name: 'Profile'}"
                   active-class="uk-active"
                   exact>
        <a>
          <img src="img/icons/user_profile.svg"
               uk-svg
               width="16"
               height="16"
               class="uk-margin-small-right">
          Профиль пользователя</a>
      </router-link>
      <li>
        <a @click.prevent="clearCache">
          <img src="img/icons/icon__trash.svg"
               uk-svg
               width="16"
               height="16"
               class="uk-margin-small-right">
          Обновить приложение
        </a>
      </li>
      <li>
        <a @click.prevent="signOut">
          <img src="img/icons/user_logout.svg"
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

export default {

  name:       'NavBarUserMenu',
  components: {
    IconSetting: () => import(/* webpackChunkName: "NavBarUserMenu" */ '../icons/IconSetting')
  },
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

    clearCache () {
      caches.keys()
            .then(cacheNames => {
              return Promise.all(
                cacheNames.filter(cacheName => {
                  // Return true if you want to remove this cache,
                  // but remember that caches are shared across
                  // the whole origin
                }).map(cacheName => {
                  return caches.delete(cacheName)
                })
              )
            })

      navigator.serviceWorker.getRegistrations()
               .then(registrations => {
                 registrations.forEach(registration => {
                   registration.unregister()
                 })
               })

      setTimeout(() => {
        location.reload(!0)
      }, 300)
    },

    signOut () {
      UIkit.modal
           .confirm('Выйти из системы!', {
             labels: {ok: 'Выйти', cancel: 'Остаться в системе'}
           })
           .then(() => {this.$store.dispatch('logout')})
           .catch(e => {})

    }
  }
}
</script>
