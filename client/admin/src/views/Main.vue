<template>
  <div class="pos-body">
    <div class="pos-main">
      <div class="pos-container">

        <!--main container-->
        <div class="pos-content">
          <transition name="slide-right"
                      mode="out-in"
                      appear>
            <router-view/>
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

  import SideBar from '../components/ui/sidebar/SideBar'
  import NavBar from '../components/ui/navbar/NavBar'

  export default {
    name:       'Main',
    components: {NavBar, SideBar},
    data () {
      return {}
    }
  }
</script>

