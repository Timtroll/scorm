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
    this.roomId = roomId
    //'https://rtcmulticonnection.herokuapp.com:443/'
    //this.socketURL = socketURL || 'wss://freee.su/api/channel/' // https://scorm.site:443/
    //this.socketURL      = socketURL || 'https://free-webrtc-server.herokuapp.com:443/' // https://scorm.site:443/

    this.socketURL      = socketURL || 'https://scorm-rtc-multi-server.herokuapp.com:443/'
    this.stunServer     = stunServer
    this.turnServer     = turnServer
    this.rtcmConnection = null

    this.localVideo  = null
    this.videoList   = []
    this.canvas      = null
    this.enableLogs  = true
    this.role        = role || 'listener' // ['teacher', 'listener']
    this.constraints = {
      hd:    {
        audio: {
          echoCancellation: true
          //noiseSuppression: true,
          //autoGainControl:  true
        },
        video: {
          width:       {min: 640, max: 1280},
          height:      {min: 360, max: 720},
          aspectRatio: 16 / 9,
          frameRate:   {min: 15.0, max: 25.0},
          //sampleRate:  1000,
          resizeMode:  'crop-and-scale' //'crop-and-scale' // 'none'
        }
      },
      sd:    {
        audio: {
          echoCancellation: true
          //noiseSuppression: true,
          //autoGainControl:  true
        },
        video: {
          width:       {min: 640, max: 640},
          height:      {min: 360, max: 320},
          aspectRatio: 16 / 9,
          frameRate:   {min: 15.0, max: 25.0},
          //sampleRate:  1000,
          resizeMode:  'crop-and-scale' //'crop-and-scale' // 'none'
        }
      },
      thumb: {
        audio: false,
        video: {
          width:       {min: 50, max: 50},
          height:      {min: 50, max: 50},
          aspectRatio: 1,
          frameRate:   {min: 1.0, max: 1.0},
          //sampleRate:  1000,
          resizeMode:  'crop-and-scale' //'crop-and-scale' // 'none'
        }
      }
    }

    this.enableAudio = true
    this.enableVideo = true

    this.screenshotFormat = 'image/jpeg'

    this.rtcmConnection                        = new RTCMultiConnection()
    this.rtcmConnection.autoCloseEntireSession = true
    this.rtcmConnection.socketURL              = this.socketURL
    this.rtcmConnection.autoCreateMediaElement = false
    this.rtcmConnection.enableLogs             = this.enableLogs
    this.rtcmConnection.autoCloseEntireSession = true

    // /node_modules/fbr/FileBufferReader.js
    // https://www.rtcmulticonnection.org/docs/send/
    this.rtcmConnection.enableFileSharing = true

    this.rtcmConnection.extra = {
      fullName: 'Your full name',
      email:    'Your email',
      photo:    'http://site.com/profile.png'
    }

    this.rtcmConnection.codecs = {
      video: 'H264', // Video codecs e.g. "h264", "vp9", "vp8" etc.
      audio: 'G722' // Audio codecs e.g. "opus", "G722", "ISAC" etc.
    }
    //this.rtcmConnection.session                = this.constraints

    this.rtcmConnection.mediaConstraints = (this.role === 'listener')
      ? this.constraints.hd
      : this.constraints.thumb

    /**
     * проверка пользователей
     * @param stream
     * @param peer
     * @returns {*}
     */
    this.rtcmConnection.autoCloseEntireSession = (stream, peer) => {
      if (peer.userid === 'xyz') {
        // do not share any stream with user "XYZ"
        return
      }

      return stream
    }

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
      //const parse    = this.turnServer.split('%')
      //const username = parse[0].split('@')[0]
      //const password = parse[0].split('@')[1]
      //const turn     = parse[1]
      //
      //console.log({
      //  urls:       turn,
      //  credential: password,
      //  username:   username
      //})
      //this.rtcmConnection.iceServers
      //    .push({
      //      urls:       turn,
      //      credential: password,
      //      username:   username
      //    })
      this.rtcmConnection.iceServers
          .push(this.turnServer)
      console.log('turn', this.rtcmConnection.iceServers)
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
    this.rtcmConnection
        .getAllParticipants()
        .forEach((pid) => {
          this.rtcmConnection.disconnectWith(pid)
        })
    this.rtcmConnection.attachStreams
        .forEach((localStream) => {
          localStream.stop()
        })
    this.rtcmConnection.closeSocket()
    this.videoList = []
  }

  // отключение пользователя по его ID
  disconnectUser (participantId) {
    this.rtcmConnection.disconnectWith(participantId)
  }

  // удаление peer пользователя по его ID
  deletePeer (participantId) {
    this.rtcmConnection.deletePeer(participantId)
  }

  // Направление трансляции
  direction (direction) {
    this.rtcmConnection.direction = direction // 'one-to-one' 'one-to-many' 'many-to-many';
  }

  capture () {
    return this.getCanvas()
               .toDataURL(this.screenshotFormat)
  }

  // https://www.rtcmulticonnection.org/docs/streamEvents/
  mute (streamId) {
    if (!streamId) return
    this.rtcmConnection.streamEvents[streamId].stream.mute('both')
  }

  unmute (streamId) {
    if (!streamId) return
    this.rtcmConnection.streamEvents[streamId].stream.unmute('both')
  }

  changeRes (res) {
    if (!res) return
    this.rtcmConnection.mediaConstraints = this.constraints[res]
  }

  // resetTrack which resets back to original track.
  resetTrack (userId) {
    this.rtcmConnection.resetTrack(userId)
  }

  // Change between camera and screen or two cameras seamlessly across all users
  replaceTrack (track, userId) {
    // var track = screenStream.getVideoTracks()[0];
    // resetTrack which resets back to original track.
    this.rtcmConnection.replaceTrack(track, userId)
  }

  getCanvas (video) {
    //let video = this.getCurrentVideo()
    console.log('video', video)
    if (video !== null && !this.ctx) {
      let canvas    = document.createElement('canvas')
      canvas.height = video.clientHeight
      canvas.width  = video.clientWidth
      this.canvas   = canvas
      this.ctx      = canvas.getContext('2d')
    }
    const {ctx, canvas} = this
    ctx.drawImage(video, 0, 0, canvas.width, canvas.height)

    console.log(canvas)
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

      console.log(
        'mediaDevices.getDisplayMedia', !!navigator.mediaDevices.getDisplayMedia,
        'getDisplayMedia', !!navigator.getDisplayMedia
      )

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
        navigator.mediaDevices
                 .getDisplayMedia({video: this.constraints.hd.video, audio: false})
                 .then(stream => {
                   onGettingSteam(stream)
                 }, getDisplayMediaError)
                 .catch(getDisplayMediaError)
      }
      else if (navigator.getDisplayMedia) {
        navigator
          .getDisplayMedia({video: this.constraints.hd.video})
          .then(stream => {
            onGettingSteam(stream)
          }, getDisplayMediaError)
          .catch(getDisplayMediaError)
      }
    }
  }

  setConstraints (connection) {
    const supports = navigator.mediaDevices.getSupportedConstraints()
    console.log('getSupportedConstraints', supports)
    let constraints = {}
    if (supports.width && supports.height) {
      constraints = {
        width:       60,
        height:      60,
        aspectRatio: 1,
        facingMode:  'face',
        frameRate:   1
      }
    }
    connection.applyConstraints({
      video: constraints
    })
  }

}
