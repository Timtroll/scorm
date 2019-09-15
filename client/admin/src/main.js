import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store/store'
import VueMeta from 'vue-meta'
import UIkit from 'uikit/dist/js/uikit.min'
import './registerServiceWorker'

import './assets/sass/styles.sass'
import i18n from './i18n'

Vue.use(VueMeta, {
  refreshOnceOnNavigation: true
})

// Or as a directive
import {VueMaskDirective} from 'v-mask'

Vue.directive('mask', VueMaskDirective);

Vue.config.productionTip = false
Vue.config.performance   = true

new Vue({
  router,
  store,
  i18n,
  render: h => h(App)
}).$mount('#app')

// directive 'v-focus' - autofocus on input
Vue.directive('focus', {
  inserted: function (el) {
    el.focus()
  }
})
