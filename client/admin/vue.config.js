module.exports = {
  runtimeCompiler:     true,
  productionSourceMap: false,

  pluginOptions: {
    i18n:   {
      locale:         'ru',
      fallbackLocale: 'ru',
      localeDir:      'locales',
      enableInSFC:    true
    },
    moment: {
      locales: ['ru']
    }
  }
}
