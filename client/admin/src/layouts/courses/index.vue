<template>
  <Card :header="false"
        :footer="false"
        :body-right="true"
        :body-right-show="editPanel_show"
        :body-padding="false">

    <!-- // Body // -->
    <template #body>

      <Finder/>

    </template>

    <!--bodyRight-->
    <template #bodyRight>
      <List :labels="'Добавить пользователя'"
            :data="editPanel_data"
            :variable-type-tield="'value'"
            :add="false"
            :folder="editPanel_folder"
            :parent="0"
            v-on:save="save($event)"
            v-on:close="closeAddGroup"/>
    </template>

  </Card>
</template>

<script>
import courses   from '@/store/modules/courses'
import protoLeaf from '@/assets/json/proto/courses/leaf.json'
//import list    from '@/assets/json/proto/finder/finder-folders.json'

export default {
  name: 'Courses',

  components: {
    Card:   () => import(/* webpackChunkName: "Card" */ '@/components/ui/card/Card'),
    List:   () => import(/* webpackChunkName: "List" */ '@/components/ui/cmsList/List'),
    Finder: () => import(/* webpackChunkName: "Finder" */ '@/components/ui/finder/Finder')
  },

  metaInfo () {
    return {
      title:         this.$route.meta.breadcrumb,
      titleTemplate: '%s - Scorm',
      htmlAttrs:     {
        lang: this.$t('app.lang')
      }
    }
  },

  data () {
    return {
      rootList: null,
      list:     null
    }
  },

  async mounted () {
    // показать кнопку меню в navBar
    this.$store.commit('navBarLeftActionShow', false)

    await this.$store.registerModule('courses', courses)

    //// запись прототипа из json в store
    this.$store.commit('set_editPanel_proto', protoLeaf)

    //// Размер панели редактирования
    await this.$store.commit('editPanel_size', false)
    this.$store.commit('card_right_show', false)

    await this.getFinderLevel('/discipline/', 'discipline')
  },

  beforeDestroy () {
    this.$store.commit('set_tree_proto', [])
    this.closeEditPanel()
    // выгрузка Vuex модуля settings
    this.$store.unregisterModule('courses')
  },

  computed: {

    loader () {
      return this.$store.getters.tree_status
    },

    pageTitle () {
      return this.$route.meta.breadcrumb
    },

    editPanel_show () {
      return this.$store.getters.cardRightState
    },

    editPanel_folder () {
      return this.$store.getters.editPanel_folder
    },

    editPanel_data () {
      return this.$store.getters.editPanel_item
    }

  },

  methods: {

    //async getFinderRoot () {
    //  await this.$store.dispatch('courses/getRoot', {route: '/discipline/'})
    //},

    async getFinderLevel (route, level, parent) {
      await this.$store.dispatch('courses/getLevel', {
        route:  route,
        level:  level,
        parent: parent
      })
    },

    save (data) {

    },

    closeAddGroup () {
      this.$store.commit('card_right_show', false)
    },

    closeEditPanel () {
      this.$store.commit('editPanel_show', false)
      this.$store.commit('set_editPanel_proto', [])
    }
  }

}
</script>

<style lang="sass">
@import "sass/index"
</style>
