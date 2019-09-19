import UIkit from 'uikit/dist/js/uikit.min'

const methods = {

  // flat tree structure
  flat (arr) {

    const tableData = []

    arr.forEach((item) => {

      let newItem = {
        label:     item.label,
        id:        item.id,
        folder:    item.folder,
        keywords:  item.keywords,
        component: item.component,
        table:     item.table
      }

      tableData.push(newItem)

      if (item.children && item.children.length > 0) {
        this.flat(item.children)
      }
    })

    return tableData
  },

  // Notifications
  notify(message, status = 'primary', timeout = '3000', pos = 'top-center'){
    UIkit.notification({
      message: message,
      status:  status,
      pos:     pos,
      timeout: timeout
    })
  }
}

export default methods
