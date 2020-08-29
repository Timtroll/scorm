<template>
  <!--login / recover form-->

  <div class="uk-container">

    <form class="pos-login"
          autocomplete="on">

      <!--Register form-->
      <div class="uk-margin-small uk-text-large uk-flex uk-flex-middle">

        <a v-if="selectedRegisterForm"
           class="uk-icon-link uk-margin-small-right"
           @click="selectedRegisterForm = null">
          <svg xmlns="http://www.w3.org/2000/svg"
               viewBox="0 0 48 48"
               width="22">
            <polyline points="33 6 15 24 33 42"
                      fill="none"
                      stroke="currentColor"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="8"/>
          </svg>
        </a>
        <span v-text="$t('signUp.title')"></span>
      </div>

      <div v-if="selectedRegisterForm">

        <div class="uk-margin-small"
             v-for="item in selectedRegisterForm">

          <div class="uk-text-small uk-text-muted">
            <span v-text="item.label"></span>
            <span class="uk-text-danger"
                  v-if="item.required"> *</span>
          </div>

          <!--text-->
          <input v-if="item.type === 'text'"
                 class="uk-input uk-width-medium"
                 :disabled="status === 'loading'"
                 :type="item.type"
                 :placeholder="item.placeholder"
                 autocomplete="username"
                 v-model="item.value">

          <!--tel-->
          <input v-if="item.type === 'tel'"
                 class="uk-input uk-width-medium"
                 :disabled="status === 'loading'"
                 pattern="[0-9]*"
                 inputmode="numeric"
                 v-mask="'+7(###)###-####'"
                 :placeholder="item.placeholder"
                 autocomplete="username"
                 v-model="item.value">

          <!--email-->
          <input v-if="item.type === 'email'"
                 class="uk-input uk-width-medium"
                 :disabled="status === 'loading'"
                 :type="item.type"
                 :placeholder="item.placeholder"
                 autocomplete="username"
                 v-model="item.value">

          <!--password-->
          <input v-if="item.type === 'password'"
                 class="uk-input uk-width-medium"
                 :disabled="status === 'loading'"
                 :type="item.type"
                 :placeholder="item.placeholder"
                 autocomplete="username"
                 v-model="item.value">

          <!--select-->
          <div v-else-if="item.type === 'select'"
               class="uk-width-1-1"
               uk-form-custom="target: > * > span:first-child">

            <select v-model="item.value"
                    :disabled="status === 'loading'">

              <option v-for="val in item.select"
                      :value="val[0]">{{ val[1] }}
              </option>
            </select>

            <button class="uk-button uk-button-default uk-width-1-1 uk-flex uk-flex-middle"
                    style="transform: none"
                    :disabled="status === 'loading'"
                    type="button"
                    tabindex="-1">
              <span class="uk-text-truncate uk-text-left uk-flex-1"></span>
              <img src="/img/icons/icon_arrow__down.svg"
                   uk-svg
                   width="14"
                   height="14">
            </button>
          </div>

          <!--date-->
          <DatePick class="uk-width-1-1"
                    v-else-if="item.type === 'date'"
                    v-model="item.value"
                    :format="'YYYY-MM-DD'"
                    :displayFormat="'DD.MM.YYYY'"
                    :selectableYearRange="5"
                    :mobileBreakpointWidth="480"
                    :inputAttributes="{class: 'uk-input uk-width-1-1', readonly: true}"
                    :pickTime="false"
                    :disabled="status === 'loading'"
                    :pickMinutes="true"
                    :placeholder="item.placeholder"
                    :months="$t('calendar.months')"
                    :weekdays="$t('calendar.weekdays')"
                    :setTimeCaption="$t('calendar.setTimeCaption')"
                    :prevMonthCaption="$t('calendar.prevMonthCaption')"
                    :nextMonthCaption="$t('calendar.nextMonthCaption')">
          </DatePick>
        </div>

        <!--submit-->
        <div class="uk-margin-small"
             v-if="formValid">
          <button type="submit"
                  :disabled="status === 'loading'"
                  class="uk-width-1-1 uk-button uk-button-default"
                  @click.prevent="signUp">
                  <span uk-spinner="ratio: .5"
                        v-if="status==='loading'"></span>
            <span v-else
                  v-text="$t('auth.fields.submit')"></span>
          </button>
        </div>

      </div>

      <!--Select Register form-->
      <ul v-else
          class="uk-list">
        <li v-for="method in registerMethods">
          <a type="button"
             @click.prevent="selectForm(method)"
             class="uk-button-link uk-display-inline-block uk-width-medium"
             v-text="method.title"></a>
        </li>
      </ul>

    </form>

    <div class="uk-margin-small-top uk-flex uk-flex-between uk-text-small">
      <router-link class="uk-link-muted"
                   :to="{name: 'Login'}"
                   v-text="$t('auth.title')"/>
    </div>
  </div>

</template>

<script>

import DatePick from '@/components/ui/datePick/DatePick'
import country  from '@/assets/json/proto/countries.json'
import timezone from '@/assets/json/proto/timezones.json'

export default {
  name: 'SignUp',

  components: {DatePick},

  metaInfo () {
    return {
      title:         this.$t('signUp.title'),
      titleTemplate: '%s - Scorm',
      htmlAttrs:     {
        lang: this.$t('app.lang')
      }
    }
  },

  data () {
    return {

      registerMethods: [
        {
          title:  'По Email',
          fields: 'email'
        },
        {
          title:  'По телефону',
          fields: 'phone'
        },
        {
          title:  'С помощью социальной сети',
          fields: null
        }
      ],

      selectedRegisterForm:   null,
      selectedRegisterMethod: null,

      register: {
        email: [
          {
            placeholder:  'ivan@email.com',
            label:        'Email',
            autocomplete: 'email',
            type:         'text',
            select:       null,
            value:        '',
            name:         'email',
            required:     true
          },
          {
            placeholder:  'Иванов',
            label:        'Фамилия',
            autocomplete: 'family-name',
            type:         'text',
            select:       null,
            value:        '',
            name:         'surname',
            required:     true
          },
          {
            placeholder:  'Иван',
            label:        'Имя',
            autocomplete: 'additional-name',
            type:         'text',
            select:       null,
            value:        '',
            name:         'name',
            required:     true
          },
          {
            placeholder:  'Иванович',
            label:        'Отчество',
            autocomplete: 'given-name',
            type:         'text',
            select:       null,
            value:        '',
            name:         'patronymic',
            required:     false
          },

          {
            placeholder:  'г. Владивосток',
            label:        'Место жительства',
            autocomplete: 'shipping locality',
            type:         'text',
            select:       null,
            value:        '',
            name:         'place',
            required:     true
          },
          {
            placeholder:  'Россия',
            label:        'Страна',
            autocomplete: 'none',
            type:         'select',
            select:       this.objectToArray(country),
            value:        '',
            name:         'country',
            required:     true
          },
          {
            placeholder:  '+3',
            label:        'Часовой пояс',
            autocomplete: 'none',
            type:         'select',
            select:       this.objectToArray(timezone),
            value:        '',
            name:         'timezone',
            required:     true
          },
          {
            placeholder:  '19.08.1980',
            label:        'Дата рождения',
            autocomplete: 'birthday',
            type:         'date',
            select:       null,
            value:        '',
            name:         'birthday',
            required:     false
          },
          {
            placeholder:  'Сложный пароль',
            label:        'Пароль',
            autocomplete: 'birthday',
            type:         'password',
            select:       null,
            value:        '',
            name:         'password',
            required:     true
          }
        ],
        phone: [
          {
            placeholder:  '+7(345) 464-5555',
            label:        'Телефон',
            autocomplete: 'tel',
            type:         'tel',
            select:       null,
            value:        '',
            name:         'phone',
            required:     true
          },
          {
            placeholder:  'Иванов',
            label:        'Фамилия',
            autocomplete: 'family-name',
            type:         'text',
            select:       null,
            value:        '',
            name:         'surname',
            required:     true
          },
          {
            placeholder:  'Иван',
            label:        'Имя',
            autocomplete: 'additional-name',
            type:         'text',
            select:       null,
            value:        '',
            name:         'name',
            required:     true
          },
          {
            placeholder:  'Иванович',
            label:        'Отчество',
            autocomplete: 'given-name',
            type:         'text',
            select:       null,
            value:        '',
            name:         'patronymic',
            required:     false
          },

          {
            placeholder:  'г. Владивосток',
            label:        'Место жительства',
            autocomplete: 'shipping locality',
            type:         'text',
            select:       null,
            value:        '',
            name:         'place',
            required:     true
          },
          {
            placeholder:  'Россия',
            label:        'Страна',
            autocomplete: 'none',
            type:         'select',
            select:       this.objectToArray(country),
            value:        '',
            name:         'country',
            required:     true
          },
          {
            placeholder:  '+3',
            label:        'Часовой пояс',
            autocomplete: 'none',
            type:         'select',
            select:       this.objectToArray(timezone),
            value:        '',
            name:         'timezone',
            required:     true
          },
          {
            placeholder:  '19.08.1980',
            label:        'Дата рождения',
            autocomplete: 'birthday',
            type:         'date',
            select:       null,
            value:        '',
            name:         'birthday',
            required:     false
          },
          {
            placeholder:  'Сложный пароль',
            label:        'Пароль',
            autocomplete: 'birthday',
            type:         'password',
            select:       null,
            value:        '',
            name:         'password',
            required:     true
          }
        ]
      }

    }
  },

  computed: {

    status () {
      return this.$store.getters.authStatus
    },

    fieldsForSave () {
      if (!this.selectedRegisterForm) return
      const object = {}
      this.selectedRegisterForm.forEach(i => {
        object[i.name] = i.value
      })
      return object
    },

    fieldsRequired () {
      if (!this.selectedRegisterForm) return false
      return this.selectedRegisterForm.filter(i => i.required)
    },

    formValid () {
      if (!this.fieldsRequired) return null
      const valid = (val) => val.value !== ''
      return this.fieldsRequired.every(valid)
      //return this.selectedRegisterForm.filter(i => i.required)
    }

  },

  methods: {

    selectForm (form) {
      this.selectedRegisterForm   = this.register[form.fields]
      this.selectedRegisterMethod = form.fields
    },

    objectToArray (obj) {
      const arr = []
      for (let prop in obj) {
        if (obj.hasOwnProperty(prop)) {
          arr.push([prop, obj[prop]])
        }
      }
      return arr
    },

    //signUp () {
    //  if (this.selectedRegisterMethod === 'email') {
    //    this.signUpEmail()
    //  }
    //  else if (this.selectedRegisterMethod === 'phone') {
    //    this.signUpPhone()
    //  }
    //},

    signUp () {
      if (this.formValid) {
        this.$store.dispatch('signUp', this.fieldsForSave)
      }
    },
    //
    //signUpPhone () {
    //  if (this.formValid) {
    //    this.$store.dispatch('signUpPhone', this.fieldsForSave)
    //  }
    //},
    //
    //signUpEmail () {
    //  if (this.formValid) {
    //    this.$store.dispatch('signUpEmail', this.fieldsForSave)
    //  }
    //}

  }

}
</script>
<style>
.vdpComponent input {font-size: 1rem}
</style>
