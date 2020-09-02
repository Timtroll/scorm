export default class Socket {

  // wss://freee.su/api/channel
  // wss://freee.su/wschannel/
  constructor (wsUrl = 'wss://freee.su/api/channel') {

    this.authorized       = false
    this.needReconnect    = true
    this.reconnectTimeout = null

    this.connect = () => {

      if (this.reconnectTimeout !== null) {
        clearTimeout(this.reconnectTimeout)
        this.reconnectTimeout = null
      }

      this.socket = new WebSocket(wsUrl)

      this.socket.onopen = async (event) => {
        console.log(`[onopen] connect to server: ${wsUrl}`)
        console.log(`[onopen] Data received from server: ${JSON.stringify(event)} ${event.data}`)
      }

      this.socket.onmessage = (event) => {
        console.log(`[onmessage] Data received from server: ${event.data}`)
      }

      this.socket.onclose = (event) => {
        if (event.wasClean) {
          console.log(`[close] Connection closed cleanly, code=${event.code} reason=${event.reason}`)
        }
        else {
          console.error('[close] Connection died')
          this.reconnect()
        }
      }

      this.socket.onerror = (error) => {
        console.error(`[error] ${error.message}`)
      }
    }

  }

  reconnect () {
    console.log('[reconnect] ')
    if (!this.needReconnect) return
    this.reconnectTimeout = setTimeout(() => {
      this.clear()
      this.connect()
    }, 5000)
  }

  auth (token) {
    console.log('Socket auth', token)
    const pack = {
      'type':  'auth',
      'token': token
    }
    socket.send(JSON.stringify(pack))
  }

  close () {
    this.socket.close(1000, 'Work complete')
  }

  clear () {
    this.authorized = false
    if (socket !== null) {
      socket.onclose = () => {}
      socket.close()
    }
  }

  send (data) {
    this.socket.send(data)
  }
}
