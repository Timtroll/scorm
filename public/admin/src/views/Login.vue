<template>
  <div class="uk-height-1-1 uk-width-1-1 uk-grid uk-grid-collapse">
    <!--logo - desktop-->
    <div
        class="uk-width-1-1 uk-width-auto@s uk-width-1-2@l uk-flex uk-flex-center uk-height-viewport uk-flex-middle uk-flex-center uk-flex-right@m uk-background-default uk-visible@m">
      <div class="uk-section">
        <div class="uk-container uk-text-center pos-login-logo-left">
          <img src="../../public/img/logo__bw.svg"
               width="100"
               class=""
               uk-svg>
          <div class="uk-margin-small-top">AD'миночка</div>
        </div>
      </div>
    </div>
    <!--login / recover form-->
    <div
        class="uk-width-1-1 uk-width-expand@s uk-width-1-2@l uk-flex uk-flex-center uk-height-viewport uk-flex-middle pos-login-background uk-flex-center uk-flex-left@l">
      <div class="uk-section uk-light">
        <div class="uk-container pos-perspective">
          <div class="uk-margin uk-hidden@m uk-text-center pos-login-logo">
            <img src="../../public/img/logo__bw.svg"
                 class=""
                 width="80"
                 uk-svg>
          </div>

          <!--auth-->
          <form>
            <div class="pos-login">
              <div class="uk-margin">
                <KeyAnimations :direction="direction"
                               :motion="motion"
                               :class="{'motion': motion, 'direction' : direction}"></KeyAnimations>
              </div>
              <div class="uk-margin">
                <div class="uk-inline">
                <span class="uk-form-icon uk-form-icon-flip"
                      uk-icon="icon: user"></span>
                  <input class="uk-input"
                         type="text"
                         placeholder="Имя пользователя"
                         v-model="auth.login"
                         v-focus
                         @keyup="keyMove">
                </div>
              </div>
              <div class="uk-margin">
                <div class="uk-inline">
                <span class="uk-form-icon uk-form-icon-flip"
                      uk-icon="icon: lock"></span>
                  <input class="uk-input"
                         v-model="auth.password"
                         type="password"
                         placeholder="Пароль"
                         @keyup="keyMove">
                </div>
              </div>
              <div class="uk-margin"
                   v-if="validateUser">
                <button type="submit"
                        class="uk-width-1-1 uk-button uk-button-default"
                        @click.prevent="authentication">Войти
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
  import KeyAnimations from '../components/auth/KeyAnimations'

  import UIkit from 'uikit/dist/js/uikit-core.min'

  let notify = (message, status = 'primary', timeout = '2000', pos = 'top-center') => {
    UIkit.notification({
      message: message,
      status:  status,
      pos:     pos,
      timeout: timeout
    })
  }

  export default {

    name: 'Auth',

    components: {KeyAnimations},

    metaInfo: {
      title:         'Авторизация',
      titleTemplate: '%s - Scorm',
      htmlAttrs:     {
        lang: 'ru'
      }
    },

    data () {

      return {

        direction: false,
        motion:    false,

        auth: {
          login:    'admin',
          password: 'admin'
        }

      }

    },

    computed: {

      validateUser () {
        return this.auth.password === 'admin' && this.auth.login === 'admin'
      }
    },

    methods: {

      // авторизация
      authentication () {
        if (this.validateUser) {
          sessionStorage.setItem('auth', 'true')
          this.$store.commit('setAuth', true)
          this.$router.push(this.$route.query.redirect || {name: 'Main'})
        } else {
          this.$store.commit('setAuth', true)
          sessionStorage.setItem('auth', 'false')
        }

      },

      // анимация при вводе логина или пароля
      keyMove () {
        clearTimeout()
        this.direction = Math.random() >= 0.5
        this.motion    = true
        setTimeout(() => this.motion = false, this.randomNumber(150, 800))
      },

      // случайное число для генерации длительности анимации
      randomNumber (min, max) {
        min = min || 100
        max = max || 1000
        return Math.floor(Math.random() * (max + 1 - min)) + min
      }
    }

  }
</script>
