<template>
  <div class="pos-body">
    <div class="pos-main">
      <div class="pos-container">

        <!--main container-->
        <div class="pos-content">
          <transition name="slide-right"
                      mode="out-in"
                      appear>
            <router-view></router-view>
          </transition>
        </div>

        <!--NavBar-->
        <NavBar></NavBar>
      </div>

      <!--sidebar-->
      <SideBar></SideBar>
    </div>
  </div>
</template>

<script>
import main       from '@/store/modules/main'
import settings   from '@/store/modules/settings'
import wssConnect from '@/api/socket'


const socket = new wssConnect('wss://freee.su/wschannel/:type')

export default {

  name: 'Main',

  components: {
    NavBar:  () => import(/* webpackChunkName: "NavBar" */ '../components/ui/navbar/NavBar'),
    SideBar: () => import(/* webpackChunkName: "SideBar" */ '../components/ui/sidebar/SideBar')
  },

  async beforeCreate () {
    //socket.connect()

    // Регистрация Vuex модулей
    await this.$store.registerModule('main', main)
    await this.$store.registerModule('settings', settings)
  },

  beforeDestroy () {
    // выгрузка Vuex модулей
    this.$store.unregisterModule('settings')
    this.$store.unregisterModule('main')
  },

  async mounted () {
  },

  methods: {

  }
}
</script>

