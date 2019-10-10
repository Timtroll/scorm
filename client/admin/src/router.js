import Vue from 'vue'
import Router from 'vue-router'
import store from './store/store.js'

Vue.use(Router)

const router = new Router({
  //mode:   'history',
  base:   process.env.BASE_URL,
  routes: [
    {
      path:      '/login',
      name:      'Login',
      component: () => import(/* webpackChunkName: "login" */ './views/Login'),
      meta:      {
        authRequired: false
      }
    },
    {
      path:           '/',
      name:           'Main',
      component:      () => import(/* webpackChunkName: "main" */ './views/Main'),
      redirect:       {name: 'Dashboard'},
      sideMenuParent: true,
      meta:           {
        authRequired: true
      },
      children:       [
        {
          path:          '/dashboard',
          name:          'Dashboard',
          component:     () => import(/* webpackChunkName: "dashboard" */ './components/dashboard/DashBoard'),
          showInSideBar: true,
          meta:          {
            authRequired: true,
            icon:         'img/icons/sidebar_dashboard.svg',
            breadcrumb:   'Рабочий стол'
          }
        },
        {
          path:      '/pages',
          name:      'Pages',
          component: () => import(/* webpackChunkName: "dashboard" */ './components/dashboard/DashBoard'),

          showInSideBar: true,
          meta:          {
            authRequired: true,
            icon:         'img/icons/sidebar_pages.svg',
            breadcrumb:   'Контент'
          }
        },
        {
          path:          '/courses',
          name:          'Courses',
          component:     () => import(/* webpackChunkName: "dashboard" */ './components/dashboard/DashBoard'),
          showInSideBar: true,
          meta:          {
            authRequired: true,
            icon:         'img/icons/sidebar_courses.svg',
            breadcrumb:   'Курсы'
          }
        },
        {
          path:          '/review',
          name:          'Review',
          component:     () => import(/* webpackChunkName: "dashboard" */ './components/dashboard/DashBoard'),
          showInSideBar: true,
          meta:          {
            authRequired: true,
            icon:         'img/icons/sidebar_review.svg',
            breadcrumb:   'Отзывы'
          }
        },
        {
          path:          '/users',
          name:          'Users',
          component:     () => import(/* webpackChunkName: "dashboard" */ './components/dashboard/DashBoard'),
          showInSideBar: true,
          meta:          {
            authRequired: true,
            icon:         'img/icons/sidebar_users.svg',
            breadcrumb:   'Пользователи'
          }
        },
        {
          path:          '/media',
          name:          'Media',
          component:     () => import(/* webpackChunkName: "dashboard" */ './components/dashboard/DashBoard'),
          showInSideBar: true,
          meta:          {
            authRequired: true,
            icon:         'img/icons/sidebar_media.svg',
            breadcrumb:   'Медиа хранилище'
          }
        },
        {
          path:          '/groups',
          name:          'Groups',
          component:     () => import(/* webpackChunkName: "dashboard" */ './components/dashboard/DashBoard'),
          //component: () => import('./components/groups/Groups'),
          showInSideBar: true,
          meta:          {
            authRequired: true,
            icon:         'img/icons/sidebar_roles.svg',
            breadcrumb:   'Управление группами пользователей'
          }
        },
        {
          path:          '/profile',
          name:          'Profile',
          component:     () => import(/* webpackChunkName: "account" */ './components/profile/Account'),
          showInSideBar: false,
          meta:          {
            authRequired: true,
            icon:         'img/icons/user_profile.svg',
            breadcrumb:   'Профиль пользователя'
          }
        },
        {
          path:          '/settings',
          name:          'Settings',
          component:     () => import(/* webpackChunkName: "settings" */ './components/settings/Settings'),
          showInSideBar: false,
          meta:          {
            authRequired: true,
            icon:         'img/icons/user_profile.svg',
            breadcrumb:   'Настройки'
          },
          children:      [
            {
              path:          '/settings/:id',
              name:          'SettingItem',
              component:     () => import(/* webpackChunkName: "table" */ './components/ui/cmsTable/Table'),
              showInSideBar: false,
              meta:          {
                authRequired: true,
                breadcrumb:   'Настройки'
              }
            }
          ]
        }
      ]
    },
    {
      path:          '/404',
      name:          'pageNotFound',
      component:     () => import('./views/PageNotFound'),
      showInSideBar: false,
      meta:          {
        authRequired: false,
        breadcrumb:   'Страница не найдена'
      }
    },
    {
      path:     '/*',
      redirect: '/404',
      name: 'pageNotFoundRedirect',
      meta:     {
        authRequired: false,
        breadcrumb:   'Страница не найдена'
      }
    }

  ]
})

router.beforeEach(
  (to, from, next) => {

    const isAuthorised = store.getters.isLoggedIn

    if (to.matched.some(record => record.meta.authRequired)) {

      if (!isAuthorised) {
        next({
          name:  'Login',
          query: {redirect: to.name}
        })
      } else {
        next()
      }
    } else {
      next()
    }
  }
)

export default router
