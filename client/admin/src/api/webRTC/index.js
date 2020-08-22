/**
 * https://github.com/westonsoftware/vue-webrtc/blob/master/src/webrtc.vue
 * FAQ https://github.com/muaz-khan/RTCMultiConnection/wiki#replace-tracks
 */
import RTCMultiConnection from 'rtcmulticonnection'

require('adapterjs')

export default class WebRtcInitMulti {

  // role: lector, listener
  constructor (role, roomId, socketURL, stunServer, turnServer) {
    this.roomId         = 'multi-chat'
    this.socketURL      = socketURL || 'https://rtcmulticonnection.herokuapp.com:443/'
    this.stunServer     = null
    this.turnServer     = null
    this.rtcmConnection = null

    this.localVideo  = null
    this.videoList   = []
    this.canvas      = null
    this.enableLogs  = false
    this.role        = role || 'listener'
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

    this.enableAudio = true
    this.enableVideo = true

    this.screenshotFormat = 'image/jpeg'

    this.rtcmConnection                        = new RTCMultiConnection()
    this.rtcmConnection.socketURL              = this.socketURL
    this.rtcmConnection.autoCreateMediaElement = false
    this.rtcmConnection.enableLogs             = this.enableLogs
    this.rtcmConnection.session                = this.constraints
    //this.rtcmConnection.mediaConstraints.audio = {
    //  mandatory: {},
    //  optional: [{
    //    echoCancellation: true,
    //    noiseSuppression: true,
    //    autoGainControl:  true
    //  }]
    //}
    //this.rtcmConnection.mediaConstraints.video = {
    //  mandatory: {},
    //  optional: [{
    //    width:       1280,
    //    height:      720,
    //    aspectRatio: 16 / 9,
    //    //frameRate:   {min: 20.0, max: 24.0},
    //    //sampleRate:  1000,
    //    resizeMode:  'crop-and-scale' //'crop-and-scale' // 'none'
    //  }]
    //}
  }

  async init () {

    this.rtcmConnection.sdpConstraints.mandatory = {
      OfferToReceiveAudio: this.enableAudio,
      OfferToReceiveVideo: this.enableVideo
    }

    if ((this.stunServer !== null) || (this.turnServer !== null)) {
      this.rtcmConnection.iceServers = [] // clear all defaults
    }

    if (this.stunServer !== null) {
      this.rtcmConnection.iceServers.push({
        urls: this.stunServer
      })
    }

    if (this.turnServer !== null) {
      const parse    = this.turnServer.split('%')
      const username = parse[0].split('@')[0]
      const password = parse[0].split('@')[1]
      const turn     = parse[1]
      this.rtcmConnection.iceServers.push({
        urls:       turn,
        credential: password,
        username:   username
      })
    }

  }

  join () {
    this.rtcmConnection
        .openOrJoin(this.roomId, (isRoomExist, roomId) => {
          if (isRoomExist === false && this.rtcmConnection.isInitiator === true) {
            console.log('opened-room', roomId)
          }
        })
  }

  leave () {
    this.rtcmConnection.attachStreams
        .forEach((localStream) => {
          localStream.stop()
        })
    this.videoList = []
  }

  capture () {
    return this.getCanvas().toDataURL(this.screenshotFormat)
  }

  getCanvas () {
    let video = this.getCurrentVideo()

    if (video !== null && !this.ctx) {
      let canvas    = document.createElement('canvas')
      canvas.height = video.clientHeight
      canvas.width  = video.clientWidth
      this.canvas   = canvas
      this.ctx      = canvas.getContext('2d')
    }
    const {ctx, canvas} = this
    ctx.drawImage(video, 0, 0, canvas.width, canvas.height)

    return canvas
  }

  getCurrentVideo () {
    if (this.localVideo === null) {
      return null
    }

    for (let i = 0, len = this.$refs.videos.length; i < len; i++) {
      if (this.$refs.videos[i].id === this.localVideo.id)
        return this.$refs.videos[i]
    }

    return null
  }

  shareScreen () {
    if (navigator.getDisplayMedia || navigator.mediaDevices.getDisplayMedia) {
      const addStreamStopListener = (stream, callback) => {
        let streamEndedEvent = 'ended'

        if ('oninactive' in stream) {
          streamEndedEvent = 'inactive'
        }

        stream.addEventListener(streamEndedEvent, () => {
          callback()
          callback = () => {}
        }, false)
      }

      const onGettingSteam = (stream) => {
        this.rtcmConnection.addStream(stream)
        console.log('share-started', stream.streamid)

        addStreamStopListener(stream, () => {
          this.rtcmConnection.removeStream(stream.streamid)
          console.log('share-stopped', stream.streamid)
        })
      }

      const getDisplayMediaError = (error) => console.log('Media error: ' + JSON.stringify(error))

      if (navigator.mediaDevices.getDisplayMedia) {
        navigator.mediaDevices.getDisplayMedia({video: this.constraints.video, audio: false})
                 .then(stream => {
                   onGettingSteam(stream)
                 }, getDisplayMediaError)
                 .catch(getDisplayMediaError)
      }
      else if (navigator.getDisplayMedia) {
        navigator.getDisplayMedia({video: this.constraints.video})
                 .then(stream => {
                   onGettingSteam(stream)
                 }, getDisplayMediaError).catch(getDisplayMediaError)
      }
    }
  }

}
