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

  export default {
    name:       'Main',
    components: {
      NavBar:  () => import(/* webpackChunkName: "NavBar" */ '../components/ui/navbar/NavBar'),
      SideBar: () => import(/* webpackChunkName: "SideBar" */ '../components/ui/sidebar/SideBar')
    }
  }
</script>

