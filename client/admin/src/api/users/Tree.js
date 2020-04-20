import Api from '../Api.js'

export default {

  // получить дерево
  get_tree () {
    return Api()({
      url:    'groups/',
      method: 'post'
    })
  }

}
