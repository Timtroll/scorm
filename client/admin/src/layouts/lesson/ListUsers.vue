<template>
  <div class="pos-lesson-users"
       v-if="users">

    <aside class="pos-lesson-user"
           v-for="user in users"
           :key="user.email">
      <div class="pos-lesson-user__ava"
           :style="{backgroundImage: `url(${user.photo})`}"></div>
    </aside>

  </div>
</template>

<script>
export default {
  name: 'ListUsers',

  components: {
    //componentName: () => import(/* webpackChunkName: "componentName" */ './componentName')
  },

  props: {
    users: {
      type:    Array,
      default: () => {}
    }
  },

  data () {
    return {}
  }
}
</script>
