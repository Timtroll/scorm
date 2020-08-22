
export default class Socket {

  constructor (wss = 'wss://freee.su/wschannel/') {

    this.socket = new WebSocket(wss)

    this.socket.onopen = async (event) => {

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
      }
    }

    this.socket.onerror = (error) => {
      console.error(`[error] ${error.message}`)
    }
  }

  close () {
    this.socket.close(1000, 'Work complete')
  }

  send (data) {
    this.socket.send(data)
  }
}
