<template>
  <!--login / recover form-->

  <div class="uk-container">

    <!--recover-->
    <form class="pos-login">

      <!--KeyAnimations-->
      <div class="uk-margin-small">
        <KeyAnimations :direction="direction"
                       :motion="motion"
                       :class="{'motion': motion, 'direction' : direction}"></KeyAnimations>
      </div>

      <div class="uk-margin-small uk-text-center uk-text-large"
           v-text="$t('confirm.title')"></div>

      <!--code-->
      <div class="uk-margin-small">
        <div class="uk-inline">
                <span class="uk-form-icon uk-form-icon-flip"
                      uk-icon="icon: user"></span>
          <input class="uk-input"
                 :disabled="status === 'loading'"
                 type="text"
                 :placeholder="$t('confirm.fields.text')"
                 v-model="confirmCode"
                 v-focus
                 @keyup="keyMove">
        </div>
      </div>

      <!--submit-->
      <div class="uk-margin"
           v-if="confirmCode && confirmCode.length">
        <button type="submit"
                :disabled="status === 'loading'"
                class="uk-width-1-1 uk-button uk-button-default"
                @click.prevent="confirm">
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
  name: 'ConfirmCode',

  components: {
    KeyAnimations: () => import(/* webpackChunkName: "KeyAnimations" */ './KeyAnimations')
  },

  metaInfo () {
    return {
      title:         this.$t('confirm.title'),
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
      background:  {
        default: 'pos-login-background',
        loading: 'uk-background-danger'
      }
    }
  },

  computed: {

    status () {
      return this.$store.getters.authStatus
    }
  },

  methods: {

    // авторизация
    confirm () {

      this.$store.dispatch('confirm', this.confirmCode)
          .then(() => this.$router.replace({
            name: 'RecoverPassword'
          }))
          .catch((err) => {})
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
