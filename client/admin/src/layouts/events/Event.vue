<template>
  <Card :loader="loading"
        :body-padding="false">

    <template #body>
      <Component v-if="eventRole"
                 :is="eventRole.component"/>
    </template>

  </Card>
</template>

<script>
import Event from '@/api/events'

export default {

  name: 'Event',

  components: {
    Card: () => import(/* webpackChunkName: "Card" */ '@/components/ui/card/Card')
  },

  metaInfo () {
    return {
      title:         this.eventMeta,
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
      }
    }
  },

  async created () {

    // Регистрация Vuex модуля settings
    //await this.$store.registerModule('lessons', lessons)
  },

  async mounted () {

    this.$store.commit('navBarLeftActionShow', false)
    this.eventApi = new Event(this.participantProfile.id)

    const event = await this.eventApi.loadUsers(this.$route.params.id)
    if (!event) {
      this.loading = 'error'
      return
    }

    const meta      = event.meta
    this.eventUsers = {
      teacher:  event.teacher,
      students: event.students
    }

    this.eventMeta = meta
    const title    = `${meta.lesson}`
    const subTitle = `<strong>${meta.discipline}: </strong>${meta.theme}`
    this.$store.commit('page_title', title)
    this.$store.commit('page_sub_title', subTitle)

    Promise.all([event])
           .then(() => {
             this.checkRoleUI(this.eventUsers)
             this.loading = 'success'
           })
  },

  async beforeDestroy () {
    //await this.leave()
    // выгрузка Vuex модуля settings
    //this.$store.unregisterModule('lessons')
  },

  computed: {

    participantProfile () {
      return this.$store.state.auth.user.profile
    }
  },

  methods: {

    checkRoleTeacher () {
      return (this.participantProfile.id === this.eventUsers.teacher.id)
        ? this.eventRoleList.teacher
        : false
    },

    checkRoleStudent () {
      return (this.eventUsers.students.find(user => user.id === this.participantProfile.id))
        ? this.eventRoleList.students
        : false
    },

    checkRoleUI () {
      if (this.checkRoleTeacher()) {
        this.eventRole = this.checkRoleTeacher()
      }
      else if (this.checkRoleStudent()) {
        this.eventRole = this.checkRoleStudent()
      }
      else {
        this.eventRole = this.eventRoleList.guest
      }
    }
  }

}
</script>

<style lang="sass">
@import "sass"
</style>
