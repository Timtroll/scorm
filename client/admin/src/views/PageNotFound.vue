<template>
  <div class="pos-body">
    <div class="pos-main">

      <div class="pos-container">
        <!--main-container-->
        <div class="pos-content uk-flex uk-flex-middle uk-flex-center uk-text-center">
          <div>
            <p class="uk-heading-2xlarge">404</p>
            <p class="uk-h4 uk-text-lowercase uk-margin-remove uk-text-muted">Такая страница не существует</p>
          </div>
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
    name:       'PageNotFound',
    components: {NavBar, SideBar},
    data () {
      return {}
    }
  }
</script>

