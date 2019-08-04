module.exports = {
  runtimeCompiler:     true,
  productionSourceMap: false,

  pluginOptions: {
    moment: {
      locales: [
        'ru'
      ]
    },
    i18n:   {
      locale:         'ru',
      fallbackLocale: 'ru',
      localeDir:      'locales',
      enableInSFC:    false
    },
    meta:   {
      projectName: 'Scorm',
      url:         'https://freee.su',
      description: 'Сервис дистанциооного обучения',
      socialImage: '/icons/android-chrome-1024x500.png'
    }
  }
}
