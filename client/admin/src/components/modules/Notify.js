import UIkit from 'uikit/dist/js/uikit.min'

//const notify

export default notify = (message, status = 'primary', timeout = '4000', pos = 'top-center') => {
  UIkit.notification({
    message: message,
    status:  status,
    pos:     pos,
    timeout: timeout
  })
}
