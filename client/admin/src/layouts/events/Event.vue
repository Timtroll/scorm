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

    //const participants = ''
    const event    = await this.eventApi.loadUsers(this.$route.params.id)
    const meta     = event.meta
    const users    = event.list
    this.eventMeta = meta
    const title    = `${meta.lesson}`
    const subTitle    = `<strong>${meta.discipline}: </strong>${meta.theme}`
    this.$store.commit('page_title', title)
    this.$store.commit('page_sub_title', subTitle)

    Promise.all([event])
           .then(() => {

             this.checkRoleUI(users)
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

    checkRole (users) {
      //TODO: переделать - ХАРДКОД!!!!

    },

    checkRoleUI (role) {
      // teacher / student
      const participantsRole = this.eventRoleList[role]
      const studentRole      = this.eventRoleList.student
      this.eventRole         = (participantsRole) ? participantsRole : studentRole
    }
  }

}
</script>

<style lang="sass">
@import "sass"
</style>
