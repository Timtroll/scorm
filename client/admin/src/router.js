import Vue    from 'vue'
import Router from 'vue-router'
import store  from './store/store.js'

Vue.use(Router)

const router = new Router({
  //mode:   'history',
  base:   process.env.BASE_URL,
  routes: [
    {
      path:      '/login',
      name:      'Start',
      component: () => import(/* webpackChunkName: "login" */ './views/Sign'),
      meta:      {
        authRequired: false
      },
      children:  [
        {
          path:          '/login',
          name:          'Login',
          component:     () => import(/* webpackChunkName: "login" */ './components/auth/LogIn'),
          showInSideBar: true,
          meta:          {
            authRequired: false
          }
        },
        {
          path:          '/sign-up',
          name:          'SignUp',
          component:     () => import(/* webpackChunkName: "login" */ './components/auth/SignUp'),
          showInSideBar: true,
          meta:          {
            authRequired: false
          }
        }
      ]
    },
    {
      path:           '/',
      name:           'Main',
      component:      () => import(/* webpackChunkName: "main" */ './views/Main'),
      redirect:       {name: 'Events'},
      sideMenuParent: true,
      meta:           {
        authRequired: true
      },
      children:       [
        {
          path:          '/dashBoard',
          name:          'DashBoard',
          component:     () => import(/* webpackChunkName: "DashBoard" */ './layouts/dashboard/DashBoard'),
          showInSideBar: true,
          meta:          {
            authRequired: true,
            icon:         'img/icons/sidebar_dashboard.svg',
            breadcrumb:   'Рабочий стол'
          }
        },
        {
          path:          '/events',
          name:          'Events',
          component:     () => import(/* webpackChunkName: "Events" */ './layouts/events/Events'),
          showInSideBar: false,
          redirect:      {name: 'DashBoard'},
          meta:          {
            authRequired: true,
            icon:         'img/icons/sidebar_dashboard.svg',
            breadcrumb:   'Уроки'
          },
          children:      [
            {
              path:           '/events/:id',
              name:           'Event',
              component:      () => import(/* webpackChunkName: "Event" */ './layouts/events/Event'),
              showInSideBar:  false,
              showInSettings: false,
              meta:           {
                root:         false,
                parentName:   'Events',
                authRequired: true,
                breadcrumb:   'Урок'
              }
            }
          ]
        },
        //{
        //  path:      '/pages',
        //  name:      'Pages',
        //  component: () => import(/* webpackChunkName: "dashboard" */ './layouts/dashboard/DashBoard'),
        //
        //  showInSideBar: true,
        //  meta:          {
        //    root:         true,
        //    authRequired: true,
        //    icon:         'img/icons/sidebar_pages.svg',
        //    breadcrumb:   'Контент'
        //  }
        //},
        {
          path:          '/courses',
          name:          'Courses',
          component:     () => import(/* webpackChunkName: "dashboard" */ './layouts/courses'),
          showInSideBar: true,
          meta:          {
            root:         true,
            authRequired: true,
            icon:         'img/icons/sidebar_courses.svg',
            breadcrumb:   'Настройки курсов'
          }
        },
        {
          path:          '/lesson',
          name:          'Lesson',
          component:     () => import(/* webpackChunkName: "dashboard" */ './layouts/lesson/Lesson'),
          showInSideBar: true,
          meta:          {
            root:         true,
            authRequired: true,
            icon:         'img/icons/sidebar_review.svg',
            breadcrumb:   'Урок'
          }
        },
        {
          path:          '/media',
          name:          'Media',
          component:     () => import(/* webpackChunkName: "Media" */ './layouts/media/Media'),
          showInSideBar: true,
          meta:          {
            root:         true,
            authRequired: true,
            icon:         'img/icons/sidebar_media.svg',
            breadcrumb:   'Медиа хранилище'
          }
        },
        {
          path:          '/profile',
          name:          'Profile',
          component:     () => import(/* webpackChunkName: "Account" */ './layouts/profile/Account'),
          showInSideBar: false,
          meta:          {
            root:         true,
            authRequired: true,
            icon:         'img/icons/user_profile.svg',
            breadcrumb:   'Профиль пользователя'
          }
        }
      ]
    },

    {
      path:                   '/config',
      name:                   'config',
      redirect:               '/Settings',
      component:              () => import(/* webpackChunkName: "main" */ './views/Main'),
      showInSideBar:          false,
      sideSettingsMenuParent: true,
      meta:                   {
        root:         true,
        authRequired: true,
        icon:         'img/icons/user_profile.svg',
        breadcrumb:   'Системные настройки'
      },
      children:               [
        {
          path:           '/settings',
          name:           'Settings',
          component:      () => import(/* webpackChunkName: "Settings" */ './layouts/settings/Settings'),
          showInSideBar:  false,
          showInSettings: true,
          meta:           {
            root:         true,
            authRequired: true,
            icon:         'img/icons/icon__settings.svg',
            breadcrumb:   'Настройки'
          },
          children:       [
            {
              path:           '/settings/:id',
              name:           'SettingItem',
              component:      () => import(/* webpackChunkName: "Table" */ './components/ui/cmsTable/Table'),
              showInSideBar:  false,
              showInSettings: false,
              meta:           {
                root:         false,
                parentName:   'Settings',
                authRequired: true,
                breadcrumb:   'Настройки'
              }
            }
          ]
        },
        {
          path:           '/groups',
          name:           'Groups',
          component:      () => import(/* webpackChunkName: "Groups" */ './layouts/groups/Groups'),
          showInSideBar:  false,
          showInSettings: true,
          meta:           {
            root:         true,
            authRequired: true,
            icon:         'img/icons/sidebar_roles.svg',
            breadcrumb:   'Управление группами пользователей'
          },
          children:       [
            {
              path:           '/groups/:id',
              name:           'GroupsItem',
              component:      () => import(/* webpackChunkName: "Table" */ './components/ui/cmsTable/Table'),
              showInSideBar:  false,
              showInSettings: false,
              meta:           {
                root:         false,
                parentName:   'Groups',
                authRequired: true,
                breadcrumb:   'Настройки'
              }
            }
          ]
        },
        {
          path:           '/users',
          name:           'Users',
          component:      () => import(/* webpackChunkName: "DashBoard" */ './layouts/users/Users'),
          showInSideBar:  false,
          showInSettings: true,
          meta:           {
            root:         true,
            authRequired: true,
            icon:         'img/icons/sidebar_users.svg',
            breadcrumb:   'Пользователи'
          }, children:    [
            {
              path:           '/users/:id',
              name:           'UsersItem',
              component:      () => import(/* webpackChunkName: "Table" */ './components/ui/cmsTable/Table'),
              showInSideBar:  false,
              showInSettings: false,
              meta:           {
                root:         false,
                parentName:   'Users',
                authRequired: true,
                breadcrumb:   'Пользователи'
              }
            }
          ]
        },

        {
          path:           '/manage-eav',
          name:           'ManageEAV',
          component:      () => import(/* webpackChunkName: "Settings" */ './layouts/manage-eav/ManageEAV'),
          showInSideBar:  false,
          showInSettings: true,
          meta:           {
            root:         true,
            authRequired: true,
            icon:         'img/icons/pos_none.svg',
            breadcrumb:   'Управление EAV'
          }
        }
      ]
    },
    {
      path:          '/404',
      name:          'pageNotFound',
      component:     () => import(/* webpackChunkName: "PageNotFound" */ './views/PageNotFound'),
      showInSideBar: false,
      meta:          {
        authRequired: false,
        breadcrumb:   'Страница не найдена'
      }
    },
    {
      path:     '/*',
      redirect: '/404',
      name:     'pageNotFoundRedirect',
      meta:     {
        authRequired: false,
        breadcrumb:   'Страница не найдена'
      }
    }

  ]
})

router.beforeEach(
  (to, from, next) => {

    if (store.state.main) {
      store.commit('page_title', '')
      store.commit('page_sub_title', '')
    }
    const isAuthorised = store.getters.isLoggedIn

    if (to.matched.some(record => record.meta.authRequired)) {

      if (!isAuthorised) {
        next({
          name:  'Login',
          query: {redirect: to.name}
        })
      }
      else {
        next()
      }
    }
    else {
      next()
    }
  }
)

export default router
