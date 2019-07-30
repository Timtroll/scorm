import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store/store'
import VueMeta from 'vue-meta'
//import Axios from 'axios'
import UIkit from 'uikit/dist/js/uikit.min'
import './registerServiceWorker'

import './assets/sass/styles.sass'

Vue.use(VueMeta, {
  refreshOnceOnNavigation: true
})

Vue.config.productionTip = false
Vue.config.performance   = true

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')

// directive 'v-focus' - autofocus on input
Vue.directive('focus', {

  inserted: function (el) {
    el.focus()
  }

})
