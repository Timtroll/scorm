<template>
  <Card :header="true"
        :header-left="false"
        :header-right="false"
        :footer="true"
        :footer-left="true"
        :footer-right="true"
        :body-left="true"
        :body-right="true"
  >

    <!--header-->
    <template #headerLeft>+</template>
    <template #headerRight>+</template>
    <template #header>header</template>

    <!--footer-->
    <template #footerLeft>+</template>
    <template #footerRight>+</template>
    <template #footer>footer</template>

    <!--Body-->
    <template #body></template>
    <template #bodyLeft>bodyLeft</template>
    <template #bodyRight>bodyRight</template>


  </Card>
</template>

<script>
  import Card from '../ui/card/Card'

  export default {

    name: 'Settings',

    components: {Card},

    data () {
      return {}
    }
  }
</script>
