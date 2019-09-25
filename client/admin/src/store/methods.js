import UIkit from 'uikit/dist/js/uikit.min'

// Плоское дерево
const flatTree = (arr) => {

  const tree = []

  const _flatTree = (arr) => {
    arr.forEach((item) => {
      let newItem = {
        folder:   item.folder,
        id:       item.id,
        name:     item.name,
        keywords: item.keywords,
        parent:   item.parent
      }

      tree.push(newItem)

      if (item.children && item.children.length > 0) {
        _flatTree(item.children)
      }
    })
  }

  _flatTree(arr)

  return tree
}

// Notifications
const notify = (message, status = 'primary', timeout = '3000', pos = 'top-center') => {
  UIkit.notification({
    message: message,
    status:  status,
    pos:     pos,
    timeout: timeout
  })

}

export {
  flatTree,
  notify
}
