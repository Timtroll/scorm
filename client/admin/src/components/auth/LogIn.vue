<template>
  <!--login / recover form-->

  <div class="uk-container ">
    <!--        <div class="uk-margin uk-hidden@m uk-text-center pos-login-logo">-->
    <!--          <img src="/img/logo__bw.svg"-->
    <!--               class=""-->
    <!--               width="60"-->
    <!--               :alt="$t('app.title')"-->
    <!--               uk-svg>-->
    <!--        </div>-->

    <!--auth-->
    <form class="pos-login">

      <!--KeyAnimations-->
      <div class="uk-margin-small">
        <KeyAnimations :direction="direction"
                       :motion="motion"
                       :class="{'motion': motion, 'direction' : direction}"></KeyAnimations>
      </div>

      <div class="uk-margin-small uk-text-center uk-text-large"
           v-text="$t('auth.title')"></div>

      <!--email-->
      <div class="uk-margin-small">
        <div class="uk-inline">
                <span class="uk-form-icon uk-form-icon-flip"
                      uk-icon="icon: user"></span>
          <input class="uk-input"
                 :disabled="status === 'loading'"
                 type="text"
                 :placeholder="$t('auth.fields.login')"
                 autocomplete="username"
                 v-model="user.login"
                 v-focus
                 @keyup="keyMove">
        </div>
      </div>

      <!--password-->
      <div class="uk-margin-small">
        <div class="uk-inline">
                <span class="uk-form-icon uk-form-icon-flip"
                      uk-icon="icon: lock"></span>
          <input class="uk-input"
                 :disabled="status === 'loading'"
                 autocomplete="current-password"
                 v-model="user.password"
                 type="password"
                 :placeholder="$t('auth.fields.password')"
                 @keyup="keyMove">
        </div>
      </div>

      <!--submit-->
      <div class="uk-margin"
           v-if="validateUser">
        <button type="submit"
                :disabled="status === 'loading'"
                class="uk-width-1-1 uk-button uk-button-default"
                @click.prevent="login">
                  <span uk-spinner="ratio: .6"
                        v-if="status==='loading'"></span>
          <span v-else
                v-text="$t('auth.fields.submit')"></span>
        </button>
      </div>

    </form>

    <div class="uk-margin-small-top uk-flex uk-flex-between uk-text-small">
      <router-link class="uk-link-muted"
                   :to="{name: 'SignUp'}"
                   v-text="$t('signUp.title')"/>
      <router-link class="uk-link-muted"
                   :to="{name: 'RecoverPassword'}"
                   v-text="$t('recover.title')"/>
    </div>

  </div>
</template>

<script>
export default {
  name: 'LogIn',

  components: {
    KeyAnimations: () => import(/* webpackChunkName: "KeyAnimations" */ './KeyAnimations')
  },

  metaInfo () {
    return {
      title:         this.$t('auth.title'),
      titleTemplate: '%s - Scorm',
      htmlAttrs:     {
        lang: this.$t('app.lang')
      }
    }
  },

  data () {
    return {
      direction: false,
      motion:    false,

      user: {
        login: '',
        password:  ''
      },

      background: {
        default: 'pos-login-background',
        loading: 'uk-background-danger'
      }
    }
  },

  computed: {

    status () {
      return this.$store.getters.authStatus
    },

    validateUser () {
      return this.user.password !== '' && this.user.login !== ''
    }
  },

  methods: {

    // авторизация
    login () {
      if (this.validateUser) {
        let login = this.user.login
        let password  = this.user.password
        this.$store.dispatch('login', {login, password})
            .then(() => this.$router.replace({
              name: 'Main'
            }))
            .catch((err) => {})
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
