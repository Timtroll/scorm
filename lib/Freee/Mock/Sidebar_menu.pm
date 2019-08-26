# На фронтенде
{
  path:          '/settings',
  name:          'Settings',
  component:     () => import('./components/settings/Settings'),
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
      component:     () => import('./components/ui/table/Table'),
      props:         {},
      showInSideBar: false,
      meta:          {
        authRequired: true,
        breadcrumb:   'Настройки'
      }
    }
  ]
}

#
{
  path:          '/settings',
  name:          'Settings',
  component:     'Settings',
  meta:          {
    authRequired: true,
    icon:         'user_profile',
    breadcrumb:   'Настройки'
  },
  children:      [
    {
      path:          '/settings/:id',
      name:          'Setting item',
      component:     'SettingsItem',
      meta:          {
        authRequired: true,
        icon:         'user_profile',
        breadcrumb:   'Настройки'
      },
    }
  ]
}
