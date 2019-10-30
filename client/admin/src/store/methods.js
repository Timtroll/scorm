import UIkit from 'uikit/dist/js/uikit.min'

/**
 * Notifications
 * @param message
 * @param status
 * @param timeout
 * @param pos
 */
function notify (message, status = 'primary', timeout = '3000', pos = 'top-center') {
  UIkit.notification({
    message: message,
    status:  status,
    pos:     pos,
    timeout: timeout
  })

}

/**
 * Плоское дерево
 * @param arr
 * @returns {[]}
 */
function flatTree (arr) {
  const tree      = []
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

/**
 * клонирование объетов
 * @param obj
 * @param hash
 * @returns {any|Set<T>}
 */
function clone (obj, hash = new WeakMap()) {

  if (Object(obj) !== obj) return obj
  if (obj instanceof Set) return new Set(obj)
  if (hash.has(obj)) return hash.get(obj)

  const result = obj instanceof Date ? new Date(obj)
    : obj instanceof RegExp ? new RegExp(obj.source, obj.flags)
      : obj.constructor ? new obj.constructor()
        : Object.create(null)

  hash.set(obj, result)

  if (obj instanceof Map)
    Array.from(obj, ([key, val]) => result.set(key, clone(val, hash)))

  return Object
    .assign(result, ...Object.keys(obj)
                             .map(key => ({[key]: clone(obj[key], hash)})))
}

/**
 *
 * @param message
 * @param ok
 * @param cancel
 * @returns {PromiseFn|PromiseFn|boolean}
 */
function confirm (message, ok, cancel) {
  return UIkit.modal.confirm(message, {
    labels: {ok: ok || 'Да', cancel: cancel || 'Отмена'}
  })
}

function dropHide (ref) {
  UIkit.dropdown(ref).hide()
}

function dropShow (ref) {
  UIkit.dropdown(ref).hide()
}

export {
  notify,
  confirm,
  flatTree,
  clone,
  dropHide,
  dropShow
}


