module.exports = {
  runtimeCompiler:     true,
  productionSourceMap: false,

  //devServer: {
  //  proxy: 'https://cors-anywhere.herokuapp.com/'
  //},

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
