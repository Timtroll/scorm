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
    this.eventApi  = new Event()
    //const participants = ''
    const event    = await this.eventApi.loadUsers(this.$route.params.id)
    this.eventMeta = event.meta
    const meta     = `<strong class="uk-text-muted">${event.meta.discipline}:</strong>
      <span class="uk-text-muted">${event.meta.theme} - </span>
      ${event.meta.lesson}`
    this.$store.commit('page_title', meta)
    Promise.all([event])
           .then(() => {

             this.checkRoleUI(event)
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
