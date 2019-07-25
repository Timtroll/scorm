/* eslint-disable no-console */

import {register} from 'register-service-worker'

if (process.env.NODE_ENV === 'production') {
  register(`${process.env.BASE_URL}service-worker.js`, {
    ready () {
      console.log(
        'App is being served from cache by a service worker.\n' +
        'For more details, visit https://goo.gl/AFskqB'
      )
    },
    registered () {
      console.log('Service worker has been registered.')
    },
    cached () {
      console.log('Content has been cached for offline use.')
    },
    updatefound () {
      console.log('New content is downloading.')
    },
    updated () {

      console.log('New content is available; please refresh.')

      const update = confirm('Доступно обновление. Нажмите "ОК" для перезагрузки')

      if (update) {

        //localStorage.clear()
        //sessionStorage.clear()

        //caches.keys()
        //      .then(cacheNames => {
        //        cacheNames
        //          .forEach(cacheName => {
        //            caches.delete(cacheName)
        //          })
        //      })

        caches.keys()
              .then(cacheNames => {
                return Promise.all(
                  cacheNames.filter(cacheName => {
                    // Return true if you want to remove this cache,
                    // but remember that caches are shared across
                    // the whole origin
                  }).map(cacheName => {
                    return caches.delete(cacheName)
                  })
                )
              })

        navigator.serviceWorker.getRegistrations()
                 .then(registrations => {
                   registrations.forEach(registration => {
                     registration.unregister()
                   })
                 })

        setTimeout(() => {
          location.reload(!0)
        }, 300)

      }

    },
    offline () {
      console.log('No internet connection found. App is running in offline mode.')
    },
    error (error) {
      console.error('Error during service worker registration:', error)
      alert(error)
    }
  })
}

/**
 * Detecting if your app is launched from the home screen
 */

// Safari
if (window.navigator.standalone === true) {
  console.log('safari display-mode is standalone')
}

// Other
if (window.matchMedia('(display-mode: standalone)').matches) {
  console.log('display-mode is standalone')
}
