/**
 * https://www.html5rocks.com/en/tutorials/webrtc/basics/
 */
require('adapterjs')

// Signaling Channel (PubNub, Firebase, Socket.io, etc.)
function SignalingChannel (peerConnection) {
  // Setup the signaling channel here
  this.peerConnection = peerConnection
}

SignalingChannel.prototype.send = (message) => {
  console.log('SignalingChannel.send', message)
  // Send messages using your favorite real-time network
}

SignalingChannel.prototype.onmessage = (message) => {
  // If we get a sdp we have to sign and return it
  if (message.sdp != null) {
    //var that = this
    this.peerConnection.setRemoteDescription(new RTCSessionDescription(message.sdp), () => {
      this.peerConnection.createAnswer((description) => {
        this.send(description)
      })
    })
  }
  else {
    this.peerConnection.addIceCandidate(new RTCIceCandidate(message.candidate))
  }
}

export default class WebRtcInit {

  constructor (selfView, remoteView) {
    this.selfView    = selfView
    this.remoteView  = remoteView
    this.signaling   = new SignalingChannel('wss://rtcmulticonnection.herokuapp.com/socket.io/')
    this.constraints = {
      audio: {
        echoCancellation: true,
        noiseSuppression: true,
        autoGainControl:  true
      },
      video: {
        width:       {min: 640, max: 1280},
        height:      {min: 360, max: 720},
        aspectRatio: 16 / 9,
        frameRate:   {min: 20.0, max: 24.0},
        //sampleRate:  1000,
        resizeMode:  'crop-and-scale' //'crop-and-scale' // 'none'
      }
    }

    this.configuration = {
      iceServers: [{urls: 'stun:stun.l.google.com:19302'}]
    }

    this.pc            = new RTCPeerConnection(this.configuration)
    this.pc.onicecandidate = ({candidate}) => this.signaling.send({candidate})

    // let the "negotiationneeded" event trigger offer generation
    this.pc.onnegotiationneeded = async () => {
      try {
        await this.pc.setLocalDescription(await this.pc.createOffer())
        // send the offer to the other peer
        this.signaling.send({desc: this.pc.localDescription})
      }
      catch (err) {
        console.error(err)
      }
    }

    // once remote track media arrives, show it in remote video element
    this.pc.ontrack = (event) => {
      // don't set srcObject again if it is already set.
      if (this.remoteView.srcObject) return
      this.remoteView.srcObject = event.streams[0]
    }

    this.signaling.onmessage = async ({desc, candidate}) => {
      try {
        if (desc) {
          // if we get an offer, we need to reply with an answer
          if (desc.type === 'offer') {
            await this.pc.setRemoteDescription(desc)
            const stream = await navigator.mediaDevices.getUserMedia(this.constraints)
            stream.getTracks().forEach((track) =>
              this.pc.addTrack(track, stream))
            await this.pc.setLocalDescription(await this.pc.createAnswer())
            this.signaling.send({desc: this.pc.localDescription})
          }
          else if (desc.type === 'answer') {
            await this.pc.setRemoteDescription(desc)
          }
          else {
            console.log('Unsupported SDP type.')
          }
        }
        else if (candidate) {
          await this.pc.addIceCandidate(candidate)
        }
      }
      catch (err) {
        console.error(err)
      }
    }
  }

  async start (selfView) {

    try {
      // get local stream, show it in self-view and add it to be sent
      const stream = await navigator.mediaDevices.getUserMedia(this.constraints)

      stream.getTracks()
            .forEach((track) => this.pc.addTrack(track, stream))

      selfView.srcObject = stream
      console.log(selfView.srcObject)
      console.log(this.remoteView.srcObject)
    }
    catch (err) {
      console.error(err)
    }
  }

}
