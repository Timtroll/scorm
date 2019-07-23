<template>
  <div class="pos-page-inner">

    <form class="uk-form-horizontal uk-width-large"
          @submit.prevent="saveChange">
      <h4 class="uk-heading-line">
        <span>Авторизация</span>
      </h4>
      <!--Логин-->
      <div class="uk-margin">
        <label class="uk-form-label">Имя</label>
        <div class="uk-form-controls">
          <div class="uk-inline uk-width-1-1">
          <span class="uk-form-icon uk-form-icon-flip"
                uk-icon="icon: user"></span>
            <input class="uk-input"
                   placeholder="Ваше Имя"
                   type="text">
          </div>
        </div>
      </div>

      <!--Email-->
      <div class="uk-margin">
        <label class="uk-form-label">Email</label>
        <div class="uk-form-controls">
          <div class="uk-inline uk-width-1-1">
          <span class="uk-form-icon uk-form-icon-flip"
                uk-icon="icon: mail"></span>
            <input class="uk-input"
                   placeholder="Ваш email"
                   v-model="user.email"
                   type="email">
          </div>
        </div>
      </div>
      <div class="uk-grid-small uk-flex-middle"
           uk-grid>
        <div class="uk-width-expand">
          <h4 class="uk-heading-line">
            <span>Сменить пароль</span>
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
                    <img src="../../../../public/img/icons/user_lock-opened.svg"
                         width="16"
                         height="16"
                         uk-svg
                         v-if="togglePassword">
                    <img src="../../../../public/img/icons/user_lock-closed.svg"
                         width="16"
                         height="16"
                         uk-svg
                         v-else>

                  </a>
                  <input class="uk-input"
                         v-model="user.password"
                         placeholder="Введите новый пароль"
                         :type="showPassword">
                </div>
              </div>
              <div class="uk-margin-bottom">
                <div class="uk-inline uk-width-1-1">
                  <input class="uk-input"
                         v-model="user.confirmPassword"
                         placeholder="Повторите новый пароль"
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
                class="uk-button uk-button-success">Сохранить
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

    metaInfo: {
      title:         'Аккаунт пользователя',
      titleTemplate: '%s - Scorm',
      htmlAttrs:     {
        lang: 'ru'
      }
    },

    data () {

      return {
        user:           {
          login:           null,
          email:           null,
          password:        null,
          confirmPassword: null
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
