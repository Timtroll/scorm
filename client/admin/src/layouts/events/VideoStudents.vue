<template>

  <!--USERS-->
  <div class="pos-lesson-users">

    <div class="pos-lesson-users-header">

      <div class="pos-lesson-users-header__title"
           v-text="$t('lesson.participants')"></div>

      <div class="uk-flex-none"
           v-if="selectedFilter">
        <button class="uk-button uk-button-small uk-button-default"
                type="button"
                v-text="selectedFilter.label">
        </button>
        <div ref="filter"
             class="uk-dropdown-small"
             uk-dropdown="mode: click; pos: bottom-right; animation: uk-animation-slide-bottom-small">
          <ul class="uk-nav uk-dropdown-nav">
            <li :class="{'uk-active': selectedFilter === item}"
                v-for="item in userFilter">
              <a href="#"
                 @click="selectFilter(item)"
                 v-text="item.label"></a></li>
          </ul>
        </div>
      </div>
    </div>

    <div class="pos-lesson-users-body">

      <div class="pos-lesson-users-list"
           v-if="users">

        <aside class="pos-lesson-user online"
               v-for="user in users"
               :key="user.email"
               @click="selectUser(user)"
               :class="{active: selectedUser === user}">

          <div class="pos-lesson-user__info">

            <div class="pos-lesson-user__info--meta"
                 v-text="user.name"></div>
          </div>

          <div class="pos-lesson-user__ava"
               :style="{backgroundImage: `url(${user.photo})`}"></div>

          <div class="pos-lesson-user__status"></div>
          <div class="pos-lesson-user__ball"
               :class="ballColor(4)"
               v-text="'4'"></div>
        </aside>

      </div>

    </div>

  </div>
</template>

<script>
import UIkit from 'uikit'

export default {
  name: 'VideoStudents',

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
    return {
      selectedUser: null,

      selectedFilter: null,
      userFilter:     [
        {id: 1, label: 'Все'},
        {id: 2, label: 'Присутствуют на занятии'},
        {id: 3, label: 'Отсутствуют на занятии'},
        {id: 4, label: 'Уже отвечали'},
        {id: 5, label: 'Еще не отвечали'}]

    }
  },

  async mounted () {
    this.selectedFilter = this.userFilter[0]
  },

  methods: {

    ballColor (ball) {
      switch (ball) {
        case (ball = 3):
          return 'warning'
        case (ball = 4):
          return 'primary'
        case (ball = 5):
          return 'success'
      }
    },

    selectFilter (item) {
      this.selectedFilter = item
      UIkit.dropdown(this.$refs.filter).hide(0)
    },

    selectUser (user) {
      if (this.selectedUser === user) {
        this.selectedUser = null
      }
      else {
        this.selectedUser = user
      }
    }
  }
}
</script>
