<template>
  <div class="pos-lesson-teach">

    <div class="pos-lesson-loader"
         v-if="connectStatus !== 'success'">
      <IconConnect :status="connectStatus"
                   :size="48"/>
      Teacher
    </div>

    <!--VideoTeachers-->
    <VideoTeachers v-if="connectStatus === 'success'"
                   :show-second-screen="true"
                   :stream="streamTeacher"/>
    <!--VideoTeachers-->

    <!--ListUsers-->
    <VideoStudents v-if="connectStatus === 'success'"
                   :users="streamStudents"
                   :connection="connection"/>
    <!--ListUsers-->

  </div>
</template>

<script>
import VideoTeachers from '@/layouts/events/VideoTeachers'
import VideoStudents from '@/layouts/events/VideoStudents'

export default {
  name: 'EventStudent',

  components: {
    VideoStudents,
    VideoTeachers,
    IconConnect: () => import(/* webpackChunkName: "IconConnect" */  '@/components/ui/icons/IconConnect')
  },

  props: {

    connection: {
      type:    Object,
      default: () => {}
    },

    teacher: {
      type:    Object,
      default: () => {}
    },

    users: {
      type:    Array,
      default: () => {}
    },

    stream: {
      type:    Array,
      default: () => {}
    }

  },

  data () {
    return {}
  },

  computed: {

    streamTeacher () {
      const teacher = this.users.find(user => user.id === this.teacher.id)
      const stream  = this.stream.find(stream => stream.userId === teacher.id)
      if (stream) {
        teacher.stream = {
          id:     stream.id,
          muted:  stream.muted,
          stream: stream.stream
        }
      }

      return teacher
    },

    streamStudents () {
      const students = this.users.filter(user => user.id !== this.teacher.id)

      students.forEach(student => {
        const stream = this.stream.find(stream => stream.userId === student.id)
        if (stream) {
          student.stream = {
            id:     stream.id,
            muted:  stream.muted,
            stream: stream.stream
          }
        }
      })

      return students
    },

    connectStatus () {
      return (this.stream) ? 'success' : 'progress'
    }
  },

  methods: {
    join () {
      //this.$emit('join')
    }
  }
}
</script>

<style lang="sass">

</style>
