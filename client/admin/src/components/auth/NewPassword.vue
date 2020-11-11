<template>
  <!--login / recover form-->

  <div class="uk-container ">


    <!--recover-->
    <form class="pos-login">

      <!--KeyAnimations-->
      <div class="uk-margin-small">
        <KeyAnimations :direction="direction"
                       :motion="motion"
                       :class="{'motion': motion, 'direction' : direction}"></KeyAnimations>
      </div>

      <div class="uk-margin-small uk-text-center uk-text-large"
           v-text="$t('newPassword.title')"></div>

      <!--password-->
      <div class="uk-margin-small">
        <div class="uk-inline">
                <span class="uk-form-icon uk-form-icon-flip"
                      uk-icon="icon: user"></span>
          <input class="uk-input"
                 :disabled="status === 'loading'"
                 type="password"
                 :placeholder="$t('newPassword.fields.password')"
                 v-model="user.password"
                 v-focus
                 @keyup="keyMove">
        </div>
      </div>

      <!--password-->
      <div class="uk-margin-small">
        <div class="uk-inline">
                <span class="uk-form-icon uk-form-icon-flip"
                      uk-icon="icon: user"></span>
          <input class="uk-input"
                 :disabled="status === 'loading'"
                 type="password"
                 :placeholder="$t('newPassword.fields.repeatPassword')"
                 v-model="user.repeatPassword"
                 v-focus
                 @keyup="keyMove">
        </div>
      </div>

      <!--submit-->
      <div class="uk-margin">
        <button type="submit"
                :disabled="status === 'loading'"
                class="uk-width-1-1 uk-button uk-button-default"
                @click.prevent="submit">
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
  name: 'NewPassword',

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
      direction:  false,
      motion:     false,
      user:       {
        password:       null,
        repeatPassword: null
      },
      background: {
        default: 'pos-login-background',
        loading: 'uk-background-danger'
      }
    }
  },

  computed: {

    validPassword () {
      return this.user.repeatPassword === this.user.password
    },
    status () {
      return this.$store.getters.authStatus
    }
  },

  methods: {

    // авторизация
    submit () {
      if (this.validPassword) {
        this.$store.dispatch('confirm', this.user.password)
            .then(() => this.$router.replace({
              name: 'Login'
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
