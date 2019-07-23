import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import './registerServiceWorker'
import i18n from './i18n'
import UIkit from 'uikit/dist/js/uikit.min'
import VueMeta from 'vue-meta'

import './assets/sass/styles.sass'

Vue.use(VueMeta, {
  refreshOnceOnNavigation: true
})

Vue.config.productionTip = false

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
