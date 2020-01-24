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
 *
 * @param data
 * @param proto
 * @returns {{groups: [], main: []}}
 */
function groupedFields (data, proto) {

  const groups = {
    main:   [],
    groups: []
  }

  //const data   = data

  if (data && proto) {
    for (let prop in data) {

      if (data && data.hasOwnProperty(prop)) {

        // Поля не объедененные в группы (видимы всегда)
        if (prop !== 'groups') {

          // только те поля, которые определены в прототипе
          const protoKey = proto.filter(item => item.name === prop)

          // установка значений полей
          for (let item of protoKey) {
            item.value = data[item.name]
          }

          if (protoKey.length === 1) {
            groups.main.push(protoKey[0])
          }

        }

        // Поля объедененные в группы
        else if (prop === 'groups') {

          const groupFields = data.groups

          groupFields.forEach(item => {

            const groupItem = {
              label:  prop.label,
              fields: []
            }

            groupItem.label       = item.label
            const groupItemFields = item.fields

            for (let propGroupField in groupItemFields) {

              // только те поля, которые определены в прототипе
              const protoKey = proto.filter(item => item.name === propGroupField)

              // установка значений полей
              for (let item of protoKey) {
                item.value = groupItemFields[item.name]
              }

              if (protoKey.length === 1) {
                groupItem.fields.push(protoKey[0])
              }
            }

            groups.groups.push(groupItem)
          })

        }

      }
    }

    return groups
  } else {
    console.error('groupedFields - no data or proto')
  }

}

/**
 *
 * @param groups
 * @returns {{}}
 */
function unGroupedFields (groups) {

  const keyValues = {}

  _getKeyValue(groups.main)

  if (groups && groups.hasOwnProperty('groups')) {
    groups.groups.forEach(item => {
      _getKeyValue(item.fileds)
    })
  }

  function _getKeyValue (item) {
    item.forEach(item => {
      //console.log(item)
      keyValues[item.name] = item.value
    })
  }

  console.log('keyValues', keyValues)

  return keyValues
}

/**
 *
 * @param groups
 * @returns {[]}
 */
function flatFields (groups) {

  const fields = []

  _getFiled(groups.main)

  if (groups.hasOwnProperty('groups')) {
    groups.groups.forEach(item => {
      _getFiled(item.fileds)
    })
  }

  function _getFiled (item) {
    item.forEach(item => {
      fields.push(item)
    })
  }

  return fields
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
  groupedFields,
  unGroupedFields,
  flatFields,
  clone,
  dropHide,
  dropShow
}


