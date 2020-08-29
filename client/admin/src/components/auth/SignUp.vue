<template>
  <!--login / recover form-->
  <div
    class="uk-width-1-1 uk-width-expand@s uk-width-1-2@l uk-flex uk-flex-center uk-height-viewport uk-flex-middle uk-flex-center uk-flex-left@l"
    :class="[status !== 'loading' ? background.default : background.loading]">
    <div class="uk-section uk-light uk-flex uk-flex-middle uk-height-1-1 uk-overflow-auto">
      <div class="uk-container pos-perspective">
        <div class="uk-margin uk-hidden@m uk-text-center pos-login-logo">
          <img src="/img/logo__bw.svg"
               class=""
               width="40"
               :alt="$t('app.title')"
               uk-svg>
        </div>

        <!--Register by Email-->
        <form class="pos-login">

          <!--login-->
          <div class="uk-margin"
               v-for="item in register.email">

            <input class="uk-input"
                   :disabled="status === 'loading'"
                   :type="item.type"
                   :placeholder="item.placeholder"
                   autocomplete="username"
                   v-model="item.value">

          </div>

          <!--          &lt;!&ndash;password&ndash;&gt;-->
          <!--          <div class="uk-margin">-->
          <!--            <div class="uk-inline">-->
          <!--                <span class="uk-form-icon uk-form-icon-flip"-->
          <!--                      uk-icon="icon: lock"></span>-->
          <!--              <input class="uk-input"-->
          <!--                     :disabled="status === 'loading'"-->
          <!--                     autocomplete="current-password"-->
          <!--                     v-model="user.pass"-->
          <!--                     type="password"-->
          <!--                     :placeholder="$t('auth.fields.password')"-->
          <!--                     @keyup="keyMove">-->
          <!--            </div>-->
          <!--          </div>-->

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
                       :to="{name: 'Login'}"
                       v-text="$t('auth.title')"/>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SignUp',

  components: {
    KeyAnimations: () => import(/* webpackChunkName: "KeyAnimations" */ './KeyAnimations')
  },

  metaInfo () {
    return {
      title:         this.$t('signUp.title'),
      titleTemplate: '%s - Scorm',
      htmlAttrs:     {
        lang: this.$t('app.lang')
      }
    }
  },

  props: {
    data: {
      type:    Object,
      default: () => {}
    }
  },

  computed: {
    //
    //validateUser () {
    //  return this.user.pass !== '' && this.user.login !== ''
    //}
  },

  data () {
    return {
      direction: false,
      motion:    false,

      register: {
        email: [
          {
            placeholder:  'Фамилия',
            autocomplete: 'username',
            type:         'text',
            select:       null,
            value:        '',
            name:         'surname',
            required:     true
          }, {
            placeholder:  'Имя',
            autocomplete: 'username',
            type:         'text',
            select:       null,
            value:        '',
            name:         'name',
            required:     true
          }, {
            placeholder:  'Отчество',
            autocomplete: 'username',
            type:         'text',
            select:       null,
            value:        '',
            name:         'patronymic',
            required:     false
          }, {
            placeholder:  'Место жительства',
            autocomplete: 'username',
            type:         'text',
            select:       null,
            value:        '',
            name:         'place',
            required:     true
          }, {
            placeholder:  'Страна',
            autocomplete: 'none',
            type:         'select',
            select:       true,
            value:        '',
            name:         'country',
            required:     true
          }, {
            placeholder:  'Часовой пояс',
            autocomplete: 'none',
            type:         'select',
            select:       true,
            value:        '',
            name:         'timezone',
            required:     true
          }, {
            placeholder:  'Дата рождения',
            autocomplete: 'birthday',
            type:         'date',
            select:       null,
            value:        '',
            name:         'birthday',
            required:     false
          }
        ],
        phone: []
      },

      background: {
        default: 'pos-login-background',
        loading: 'uk-background-danger'
      }
    }
  },

  methods: {

    // авторизация
    signIn () {
      //if (this.validateUser) {
      //  let login = this.user.login
      //  let pass  = this.user.pass
      //  this.$store.dispatch('login', {login, pass})
      //      .then(() => this.$router.push({
      //        name: 'Main'
      //      }))
      //      .catch((err) => {})
      //}
    }

  }

}
</script>
