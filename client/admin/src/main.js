import Vue     from 'vue'
import App     from './App.vue'
import router  from './router'
import store   from './store/store'
import VueMeta from 'vue-meta'
import UIkit   from 'uikit/dist/js/uikit.min'
import './registerServiceWorker'
import i18n    from './i18n'
import './assets/sass/styles.sass'

Vue.use(VueMeta, {
  refreshOnceOnNavigation: true
})

// VueMaskDirective
import VueMaskDirective from 'vue-mask-directive'

Vue.use(VueMaskDirective)

// Vue2 Touch Events
import Vue2TouchEvents from 'vue2-touch-events'

Vue.use(Vue2TouchEvents, {
  touchClass:          'pos-touch', // Add an extra CSS class when touch start, and remove it when touch end.
                                    // This is a global config, and you can use v-touch-class directive to overwrite this setting in a single component.
  tapTolerance:        10,  // default 10. The tolerance to ensure whether the tap event effective or not.
  swipeTolerance:      80,  // default 30. The tolerance to ensure whether the swipe event effective or not.
  longTapTimeInterval: 400  // default 400 in millisecond.
                            // The minimum time interval to detect whether long tap event effective or not.
})

Vue.config.productionTip = false
Vue.config.performance   = true

import AppConfig from '../public/config'

export let appConfig = new AppConfig()

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
