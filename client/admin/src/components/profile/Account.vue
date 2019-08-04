<template>
  <div class="pos-page-inner">

    <form class="uk-form-horizontal uk-width-large"
          autocomplete="on"
          @submit.prevent="saveChange">
      <h4 class="uk-heading-line">
        <span v-text="$t('profile.user.title')"></span>
      </h4>

      <!--Name-->
      <div class="uk-margin">
        <label class="uk-form-label">
          <span v-text="$t('profile.user.name')"></span>
          <span class="uk-text-danger"
                v-if="user.name.required"> *</span>
        </label>
        <div class="uk-form-controls">
          <div class="uk-inline uk-width-1-1">
          <span class="uk-form-icon uk-form-icon-flip"
                uk-icon="icon: user"></span>
            <input class="uk-input"
                   v-model="user.name.val"
                   autocomplete="name"
                   :placeholder="$t('profile.user.namePlaceholder')"
                   type="text">
          </div>
        </div>
      </div>

      <!--Логин-->
      <div class="uk-margin">
        <label class="uk-form-label">
          <span v-text="$t('profile.user.userName')"></span>
          <span class="uk-text-danger"
                v-if="user.username.required"> *</span>
        </label>
        <div class="uk-form-controls">
          <div class="uk-inline uk-width-1-1">
          <span class="uk-form-icon uk-form-icon-flip"
                uk-icon="icon: user"></span>
            <input class="uk-input"
                   v-model="user.user"
                   autocomplete="username"
                   :placeholder="$t('profile.user.userNamePlaceholder')"
                   type="text">
          </div>
        </div>
      </div>

      <!--Email-->
      <div class="uk-margin">
        <label class="uk-form-label">
          <span v-text="$t('profile.user.email')"></span>
          <span class="uk-text-danger"
                v-if="user.email.required"> *</span>
        </label>
        <div class="uk-form-controls">
          <div class="uk-inline uk-width-1-1">
          <span class="uk-form-icon uk-form-icon-flip"
                uk-icon="icon: mail"></span>
            <input class="uk-input"
                   autocomplete="email"
                   :placeholder="$t('profile.user.emailPlaceholder')"
                   v-model="user.email.val"
                   type="email">
          </div>
        </div>
      </div>

      <!--Phone-->
      <div class="uk-margin">
        <label class="uk-form-label">
          <span v-text="$t('profile.user.phone')"></span>
          <span class="uk-text-danger"
                v-if="user.phone.required"> *</span>
        </label>
        <div class="uk-form-controls">
          <div class="uk-inline uk-width-1-1">
          <span class="uk-form-icon uk-form-icon-flip"
                uk-icon="icon: mail"></span>
            <input class="uk-input"
                   :placeholder="$t('profile.user.phonePlaceholder')"
                   autocomplete="tel"
                   v-model="user.phone.val"
                   v-mask="'+7 (###) ###-##-##'"
                   type="text">
          </div>
        </div>
      </div>

      <!--Город-->
      <div class="uk-margin">
        <label class="uk-form-label">
          <span v-text="$t('profile.user.city')"></span>
          <span class="uk-text-danger"
                v-if="user.city.required"> *</span>
        </label>
        <div class="uk-form-controls">
          <div class="uk-inline uk-width-1-1">
          <span class="uk-form-icon uk-form-icon-flip"
                uk-icon="icon: mail"></span>
            <input class="uk-input"
                   :placeholder="$t('profile.user.cityPlaceholder')"
                   autocomplete="address-level1"
                   v-model="user.city.val"
                   type="text">
          </div>
        </div>
      </div>

      <!--dateOfBirth-->
      <div class="uk-margin">
        <label class="uk-form-label">
          <span v-text="$t('profile.user.dateOfBirth')"></span>
          <span class="uk-text-danger"
                v-if="user.dateOfBirth.required"> *</span>
        </label>
        <div class="uk-form-controls">
          <div class="uk-inline uk-width-1-1">
          <span class="uk-form-icon uk-form-icon-flip"
                uk-icon="icon: mail"></span>
            <input class="uk-input"
                   autocomplete="bday"
                   v-mask="'##.##.####'"
                   :placeholder="$t('profile.user.dateOfBirthPlaceholder')"
                   v-model="user.dateOfBirth.val"
                   type="text">
          </div>
        </div>
      </div>

      <!--Сменить пароль-->
      <div class="uk-grid-small uk-flex-middle"
           uk-grid>
        <div class="uk-width-expand">
          <h4 class="uk-heading-line">
            <span v-text="$t('profile.password.title')"></span>
          </h4>
        </div>
        <div class="uk-width-auto">
          <label @click="changePassword = !changePassword">
            <input type="checkbox"
                   :checked="changePassword"
                   v-model="changePassword"
                   class="pos-checkbox-switch right">
          </label>
        </div>
      </div>

      <!--Password-->
      <div class="uk-margin"
           v-if="changePassword">
        <div class="uk-form-label"></div>
        <div class="uk-form-controls">

          <transition name="scale"
                      mode="out-in"
                      appear>
            <div
                class="uk-margin-top">
              <div class="uk-margin-bottom">
                <div class="uk-inline uk-width-1-1">
                  <a class="uk-form-icon uk-form-icon-flip"
                     @click.prevent="togglePassword = !togglePassword"
                     :class="{'uk-text-danger': !togglePassword, 'uk-text-success': togglePassword }">
                    <img src="../../../public/img/icons/user_lock-opened.svg"
                         width="16"
                         height="16"
                         uk-svg
                         v-if="togglePassword">
                    <img src="../../../public/img/icons/user_lock-closed.svg"
                         width="16"
                         height="16"
                         uk-svg
                         v-else>

                  </a>
                  <input class="uk-input"
                         v-model="user.password.val"
                         autocomplete="new-password"
                         :placeholder="$t('profile.password.passwordPlaceholder')"
                         :type="showPassword">
                </div>
              </div>
              <div class="uk-margin-bottom">
                <div class="uk-inline uk-width-1-1">
                  <input class="uk-input"
                         v-model="user.confirmPassword.val"
                         autocomplete="new-password"
                         :placeholder="$t('profile.password.repeatPasswordPlaceholder')"
                         :type="showPassword">
                </div>
              </div>
            </div>
          </transition>
        </div>
      </div>

      <!--Save-->
      <div class="uk-margin uk-text-right">
        <button type="submit"
                class="uk-button uk-button-success"
                v-text="$t('actions.save')">
        </button>
      </div>
    </form>
  </div>
</template>

<script>
  import UIkit from 'uikit/dist/js/uikit'

  let notify = (message, status = 'primary', timeout = '2000', pos = 'top-center') => {
    UIkit.notification({
      message: message,
      status:  status,
      pos:     pos,
      timeout: timeout
    })
  }

  export default {

    name: 'Account',

    metaInfo () {
      return {
        title:         this.$t('profile.user.title'),
        titleTemplate: '%s - Scorm',
        htmlAttrs:     {
          lang: this.$t('app.lang')
        }
      }
    },

    data () {

      return {
        user:           {
          username:        {
            val:      null,
            required: false
          },
          name:            {
            val:      null,
            required: true
          },
          email:           {
            val:      null,
            required: true
          },
          phone:           {
            val:      null,
            required: true
          },
          city:            {
            val:      null,
            required: true
          },
          dateOfBirth:     {
            val:      null,
            required: false
          },
          password:        {
            val:      null,
            required: true
          },
          confirmPassword: {
            val:      null,
            required: true
          }
        },
        changePassword: false,
        togglePassword: false
      }
    },

    computed: {

      lockIcon () {
        if (this.togglePassword) {
          return 'unlock'
        } else {
          return 'lock'
        }
      },

      showPassword () {

        if (this.togglePassword) {
          return 'text'
        } else {
          return 'password'
        }
      }
    },

    methods: {

      saveChange () {
        notify('Данные аккаунта успешно сохранены', 'success')
      }
    }

  }
</script>
