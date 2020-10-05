<template>
  <Card :loader="loading"
        :body-padding="false">

    <template #body>
      <Component v-if="eventRole"
                 :stream="video"
                 :users="allEvenUsers"
                 :teacher="eventUsers.teacher"
                 :is="eventRole.component"/>
    </template>

  </Card>
</template>

<script>
import Event           from '@/api/events'
import eventStore      from './store'
import WebRtcInitMulti from '@/api/webRTC'
//import eventApi        from '@/api/events'
import * as io         from 'socket.io-client'
import lessonApi       from '@/api/events'
import {appConfig}     from '@/main'

window.io = io

export default {

  name: 'Event',

  components: {
    Card: () => import(/* webpackChunkName: "Card" */ '@/components/ui/card/Card')
  },

  metaInfo () {
    return {
      title:         this.pageTitle,
      titleTemplate: '%s - ' + this.$t('app.title'),
      htmlAttrs:     {
        lang: this.$t('app.lang')
      }
    }
  },

  data () {
    return {
      loading:  'loading',
      eventApi: null,

      eventMeta:  null,
      eventUsers: null,

      allEvenUsers: null,

      eventRole:     null,
      eventRoleList: {
        teacher: {
          name:      'teacher',
          component: () => import(/* webpackChunkName: "EventTeacher" */ './EventTeacher')
        },
        student: {
          name:      'student',
          component: () => import(/* webpackChunkName: "EventStudent" */ './EventStudent')
        },
        guest:   {
          name:      'guest',
          component: () => import(/* webpackChunkName: "EventGuest" */ './EventGuest')
        }
      },

      connection: null,

      video: []
    }
  },

  async created () {

    // Регистрация Vuex модуля settings
    await this.$store.registerModule('eventStore', eventStore)
  },

  async mounted () {

    const eventId = this.$route.params.id

    this.$store.commit('navBarLeftActionShow', false)
    this.$store.commit('eventStore/lessonID')
    this.eventApi = new Event(eventId)

    this.lessonApi = new lessonApi(eventId)

    const event = await this.eventApi.loadUsers(eventId)

    if (!event) {
      this.loading = 'error'
      return
    }

    Promise.all([event])
           .then(() => {

             const meta        = event.meta
             this.eventUsers   = {
               teacher:  event.teacher,
               students: event.students
             }
             this.allEvenUsers = [...event.students, event.teacher]

             this.eventMeta = meta
             const title    = `${meta.lesson}`
             const subTitle = `<strong>${meta.discipline}: </strong>${meta.theme}`
             this.$store.commit('page_title', title)
             this.$store.commit('page_sub_title', subTitle)

             this.checkRoleUI(this.eventUsers)
             this.loading = 'success'
             this.startRTC()
           })

    //this.$nextTick(() => {
    //
    //})
  },

  //async beforeDestroy () {
  //  //await this.leave()
  //  // выгрузка Vuex модуля settings
  //  this.$store.unregisterModule('eventStore')
  //},

  beforeRouteLeave (to, from, next) {
    this.$store.unregisterModule('eventStore')
    this.leave()
    next()
  },

  computed: {

    // event id
    roomId () {
      return this.$route.params.id
    },

    // заголовок страницы, тег title
    pageTitle () {
      return (this.eventMeta) ? this.eventMeta.lesson : ''
    },

    // профиль пользователя
    participantProfile () {
      return this.$store.state.auth.user.profile
    }
  },

  methods: {

    // проверка на учителя
    checkRoleTeacher () {
      if (!this.eventUsers) return
      return (this.participantProfile.id === this.eventUsers.teacher.id)
    },

    // проверка на ученика
    checkRoleStudent () {
      if (!this.eventUsers) return
      return !!(this.eventUsers.students.find(user => user.id === this.participantProfile.id))
    },

    // проверка пользователя для отображения необходимого интерфейса
    checkRoleUI () {
      if (this.checkRoleTeacher()) {
        this.eventRole = this.eventRoleList.teacher
      }
      else if (this.checkRoleStudent()) {
        this.eventRole = this.eventRoleList.student
      }
      else {
        this.eventRole = this.eventRoleList.guest
      }
    },

    // инициация WebRtc
    startRTC () {
      this.connection = new WebRtcInitMulti(
        this.eventRole.name,
        this.roomId,
        appConfig.wssWebRTC,
        appConfig.stunServer,
        appConfig.turnServer,
        JSON.parse(localStorage.getItem('profile'))
      )
      //this.connection.init(this.$refs.local, this.$refs.video)
      this.getStream()
      this.join()
    },

    join () {
      if (!this.connection) return
      this.connection.join()
    },

    leave () {
      if (!this.connection) return
      this.connection.leave()
    },

    getStream () {
      if (!this.connection.rtcmConnection) return

      this.connection.rtcmConnection.onstream = (stream) => {

        let found = this.connection.videoList.find(video => {
          return video.userId === stream.extra.userId
        })

        console.log('found', found)

        if (found === undefined) {
          const video = {
            id:      stream.streamid,
            userId:  this.participantProfile.id,
            profile: this.allEvenUsers.find(i => i.id === this.participantProfile.id),
            muted:   stream.type === 'local',
            stream:  stream.stream
          }

          //this.setConstraints(video.stream)

          this.connection.videoList.push(video)
          this.video.push(video)

          //if (stream.type === 'local') {
          //  this.connection.localVideo = video
          //  this.$refs.local.srcObject = this.connection.localVideo.stream
          //}
        }

        //if (this.connection.localVideo) {
        //  this.connection.videoList = this.connection.videoList
        //                                  .filter(i => i.userId !== this.connection.localVideo.stream.extra.userId)
        //}

        //setTimeout(() => {
        //  if (!this.$refs.video) return
        //  const videoList = this.$refs.video
        //  //if (videoList.length) return
        //  const video     = videoList.find(i => i.id === stream.streamid)
        //  if (!video) return
        //  video.srcObject = stream.stream
        //}, 100)

        console.log('joined-room', stream)
      }

      this.connection.rtcmConnection.onstreamended = (stream) => {
        const newList = []

        this.connection.videoList.forEach((item) => {
          if (item.userId !== stream.extra.userId) {
            newList.push(item)
          }
        })

        this.connection.videoList = newList
        this.video                = newList

        console.log('left-room', stream.streamid)
      }
    }
  }

}
</script>

<style lang="sass">
@import "sass"

</style>
