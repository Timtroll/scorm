import Vue from 'vue'
import Router from 'vue-router'
import store from './store'

Vue.use(Router)

const router = new Router({
  mode:   'history',
  base:   process.env.BASE_URL,
  routes: [
    {
      path:      '/login',
      name:      'Login',
      component: () => import('./views/Login'),
      meta:      {
        authRequired: false
      }
    }, {
      path:           '/',
      name:           'Main',
      component:      () => import('./views/Main'),
      redirect:       {name: 'Dashboard'},
      sideMenuParent: true,
      meta:           {
        authRequired: true
      }, children:    [
        {
          path:          '/dashboard',
          name:          'Dashboard',
          component:     () => import('./components/dashboard/DashBoard'),
          props:         {},
          showInSideBar: true,
          meta:          {
            authRequired: true,
            icon:         'img/icons/sidebar_dashboard.svg',
            breadcrumb:   'Рабочий стол'
          }
        }, {
          path:          '/pages',
          name:          'Pages',
          component:     () => import('./components/dashboard/DashBoard'),
          props:         {},
          showInSideBar: true,
          meta:          {
            authRequired: true,
            icon:         'img/icons/sidebar_pages.svg',
            breadcrumb:   'Контент'
          }
        }, {
          path:          '/courses',
          name:          'Courses',
          component:     () => import('./components/dashboard/DashBoard'),
          props:         {},
          showInSideBar: true,
          meta:          {
            authRequired: true,
            icon:         'img/icons/sidebar_courses.svg',
            breadcrumb:   'Курсы'
          }
        }, {
          path:          '/review',
          name:          'Review',
          component:     () => import('./components/dashboard/DashBoard'),
          props:         {},
          showInSideBar: true,
          meta:          {
            authRequired: true,
            icon:         'img/icons/sidebar_review.svg',
            breadcrumb:   'Отзывы'
          }
        }, {
          path:          '/users',
          name:          'Users',
          component:     () => import('./components/dashboard/DashBoard'),
          props:         {},
          showInSideBar: true,
          meta:          {
            authRequired: true,
            icon:         'img/icons/sidebar_users.svg',
            breadcrumb:   'Пользователи'
          }
        }, {
          path:          '/media',
          name:          'Media',
          component:     () => import('./components/dashboard/DashBoard'),
          props:         {},
          showInSideBar: true,
          meta:          {
            authRequired: true,
            icon:         'img/icons/sidebar_media.svg',
            breadcrumb:   'Медиа хранилище'
          }
        }, {
          path:          '/profile',
          name:          'Profile',
          component:     () => import('./components/ui/settings/Account'),
          props:         {},
          showInSideBar: false,
          meta:          {
            authRequired: true,
            icon:         'img/icons/user_profile.svg',
            breadcrumb:   'Профиль пользователя'
          }
        }
      ]
    }, {
      path:          '/404',
      name:          'pageNotFound',
      component:     () => import('./views/PageNotFound'),
      showInSideBar: false,
      meta:          {
        authRequired: false
      }
    }, {
      path:     '/*',
      redirect: '/404',
      meta:     {authRequired: false}
    }

  ]
})

router.beforeEach((to, from, next) => {

  //const isAuthorised = store.state.user.isAuthorised
  const isAuthorised = sessionStorage.getItem('auth')

  if (to.matched.some(record => record.meta.authRequired)) {

    if (!isAuthorised) {
      next({
        name:  'Login',
        query: {redirect: to.fullPath}
      })
    } else {
      next()
    }
  } else {
    next()
  }
})

export default router
