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

    <!--recover-->
    <form class="pos-login">

      <!--KeyAnimations-->
      <div class="uk-margin-small">
        <KeyAnimations :direction="direction"
                       :motion="motion"
                       :class="{'motion': motion, 'direction' : direction}"></KeyAnimations>
      </div>

      <div class="uk-margin-small uk-text-center uk-text-large"
           v-text="$t('recover.title')"></div>

      <!--email-->
      <div class="uk-margin-small">
        <div class="uk-inline">
                <span class="uk-form-icon uk-form-icon-flip"
                      uk-icon="icon: user"></span>
          <input class="uk-input"
                 :disabled="status === 'loading'"
                 type="email"
                 :placeholder="$t('recover.fields.email')"
                 autocomplete="email"
                 v-model="user.email"
                 v-focus
                 @keyup="keyMove">
        </div>
      </div>

      <!--submit-->
      <div class="uk-margin"
           v-if="validateUser">
        <button type="submit"
                :disabled="status === 'loading'"
                class="uk-width-1-1 uk-button uk-button-default"
                @click.prevent="recover">
                  <span uk-spinner="ratio: .6"
                        v-if="status==='loading'"></span>
          <span v-else
                v-text="$t('recover.fields.submit')"></span>
        </button>
      </div>

    </form>

    <!--confirm code-->
    <form class="pos-login">

      <div class="uk-margin-small uk-text-center uk-text-large"
           v-text="$t('confirm.title')"></div>

      <!--email-->
      <div class="uk-margin-small">
        <div class="uk-inline">
                <span class="uk-form-icon uk-form-icon-flip"
                      uk-icon="icon: user"></span>
          <input class="uk-input"
                 :disabled="status === 'loading'"
                 type="email"
                 :placeholder="$t('confirm.fields.text')"
                 autocomplete="email"
                 v-model="confirmCode"
                 v-focus
                 @keyup="keyMove">
        </div>
      </div>

      <!--submit-->
      <div class="uk-margin"
           v-if="validateUser">
        <button type="submit"
                :disabled="status === 'loading'"
                class="uk-width-1-1 uk-button uk-button-default"
                @click.prevent="recover">
                  <span uk-spinner="ratio: .6"
                        v-if="status==='loading'"></span>
          <span v-else
                v-text="$t('confirm.fields.submit')"></span>
        </button>
      </div>

    </form>

    <div class="uk-margin-small-top uk-flex uk-flex-between uk-text-small">
      <router-link class="uk-link-muted"
                   :to="{name: 'Login'}"
                   v-text="$t('auth.title')"/>
      <router-link class="uk-link-muted"
                   :to="{name: 'SignUp'}"
                   v-text="$t('signUp.title')"/>
    </div>

  </div>
</template>

<script>
export default {
  name: 'RecoverPassword',

  components: {
    KeyAnimations: () => import(/* webpackChunkName: "KeyAnimations" */ './KeyAnimations')
  },

  metaInfo () {
    return {
      title:         this.$t('recover.title'),
      titleTemplate: '%s - Scorm',
      htmlAttrs:     {
        lang: this.$t('app.lang')
      }
    }
  },

  data () {
    return {
      direction:   false,
      motion:      false,
      confirmCode: null,
      user:        {
        email: ''
      },

      emailRegExp: /^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i,

      background: {
        default: 'pos-login-background',
        loading: 'uk-background-danger'
      }
    }
  },

  computed: {

    validateUser () {
      return this.emailRegExp.test(this.user.email)
    },

    status () {
      return this.$store.getters.authStatus
    }
  },

  methods: {

    // авторизация
    recover () {
      if (this.validateUser) {
        let login    = this.user.login
        let password = this.user.password
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
