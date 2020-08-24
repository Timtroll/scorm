/**
 * https://github.com/westonsoftware/vue-webrtc/blob/master/src/webrtc.vue
 * FAQ https://github.com/muaz-khan/RTCMultiConnection/wiki#replace-tracks
 */

/** Examples:
 * https://github.com/webrtc/FirebaseRTC/blob/master/public/app.js
 * https://github.com/openrtc-io/awesome-webrtc
 * https://www.twilio.com/blog/2014/12/set-phasers-to-stunturn-getting-started-with-webrtc-using-node-js-socket-io-and-twilios-nat-traversal-service.html
 * Free Stun-turn server https://www.twilio.com/stun-turn | Google's public STUN server (stun.l.google.com:19302)
 * https://www.npmjs.com/package/stun
 * https://github.com/shahidcodes/webrtc-video-call-example-nodejs/blob/master/index.js
 * https://www.html5rocks.com/en/tutorials/webrtc/infrastructure/
 *
 * https://github.com/simplewebrtc/SimpleWebRTC
 * free-webrtc-server - SimpleWebRTC
 *    url https://free-webrtc-server.herokuapp.com:8888
 *    docs - https://elements.heroku.com/buttons/florindumitru/signalmaster/
 *           https://github.com/florindumitru/signalmaster
 *
 * https://rtcmulticonnection.herokuapp.com/demos/
 *
 * https://github.com/versatica/mediasoup/
 */

import RTCMultiConnection from 'rtcmulticonnection'

//require('adapterjs')
import adapter from 'webrtc-adapter'

console.log(adapter.browserDetails)

export default class WebRtcInitMulti {

  // role: lector, listener
  constructor (role, roomId, socketURL, stunServer, turnServer) {
    this.roomId    = 'multi-chat'
    //'https://rtcmulticonnection.herokuapp.com:443/'
    this.socketURL = socketURL || 'https://scorm-rtc-multi-server.herokuapp.com:443/' // https://scorm.site:443/
    //this.socketURL      = socketURL || 'https://free-webrtc-server.herokuapp.com:443/'
    this.stunServer     = null
    this.turnServer     = null
    this.rtcmConnection = null

    this.localVideo  = null
    this.videoList   = []
    this.canvas      = null
    this.enableLogs  = true
    this.role        = role || 'listener'
    this.constraints = {
      audio: {
        echoCancellation: true
        //noiseSuppression: true,
        //autoGainControl:  true
      },
      video: {
        width:       {min: 1280, max: 1280},
        height:      {min: 720, max: 720},
        aspectRatio: 16 / 9,
        frameRate:   {min: 12.0, max: 24.0},
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
    //this.rtcmConnection.session                = this.constraints

    this.rtcmConnection.mediaConstraints = this.constraints
    //this.rtcmConnection.mediaConstraints = {
    //  audio: {
    //    mandatory: {
    //      echoCancellation:     true, // disabling audio processing
    //      googAutoGainControl:  true,
    //      googNoiseSuppression: true,
    //      googHighpassFilter:   true
    //      //googTypingNoiseDetection: true
    //      //googAudioMirroring: true
    //    }
    //  },
    //
    //  video: {
    //    mandatory: {
    //      minAspectRatio: 16 / 9,
    //      //resizeMode:     'crop-and-scale',
    //      minFrameRate:   15,
    //      maxFrameRate:   25,
    //      minWidth:       640,
    //      maxWidth:       1280,
    //      minHeight:      360,
    //      maxHeight:      720
    //    },
    //    optional:  [
    //      {
    //        facingMode: 'user' // or "application"
    //      }
    //    ]
    //  }
    //  //mandatory: {},
    //  //optional:  [{
    //  //  width:       1280,
    //  //  height:      720,
    //  //  aspectRatio: 16 / 9,
    //  //  //frameRate:   {min: 20.0, max: 24.0},
    //  //  //sampleRate:  1000,
    //  //  resizeMode:  'crop-and-scale' //'crop-and-scale' // 'none'
    //  //}]
    //}

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
    return this.getCanvas()
               .toDataURL(this.screenshotFormat)
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

  //setConstraints (connection) {
  //  const supports = navigator.mediaDevices.getSupportedConstraints()
  //  console.log('getSupportedConstraints', supports)
  //  let constraints = {}
  //  if (supports.width && supports.height) {
  //    constraints = {
  //      width:            128,
  //      height:           72,
  //      aspectRatio:      16 / 9,
  //      echoCancellation: true,
  //      facingMode:       'face',
  //      frameRate:        1
  //    }
  //  }
  //  connection.applyConstraints({
  //    video: constraints
  //  })
  //}

}
