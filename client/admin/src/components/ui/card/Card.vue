<template>
  <div class="pos-card">

    <!--header-->
    <div class="pos-card-header"
         v-if="header">

      <a class="pos-card-header-item link"
         :class="{'uk-text-danger' : bodyLeftShow}"
         @click.prevent="bodyLeftToggle()">
        <img src="/img/icons/icon__nav.svg"
             uk-svg
             width="20"
             height="20">
      </a>
      <!--headerLeft-->
      <div class="pos-card-header-item"
           v-if="headerLeft">
        <slot name="headerLeft"></slot>
      </div>

      <!--header content-->
      <div class="pos-card-header--content">
        <slot name="header"></slot>
      </div>

      <!--headerRight-->
      <div class="pos-card-header-item"
           v-if="headerRight">

        <slot name="headerRight"></slot>
      </div>
      <a class="pos-card-header-item link"
         :class="{'uk-text-danger' : bodyRightShow}"
         @click.prevent="bodyRightToggle()">
        <img src="/img/icons/icon__info.svg"
             uk-svg
             width="20"
             height="20">

      </a>

    </div>

    <!--content-->
    <div class="pos-card-body">

      <!--content-middle-->
      <div class="pos-card-body-middle"
           ref="body"
           :class="{'pos-padding': bodyPadding}">
        <slot name="body">{{bodyWidth}}</slot>
      </div>

      <!--content-left-->
      <transition name="slide-left">
        <div class="pos-card-body-left"
             v-if="bodyLeft && bodyLeftShow"
             :class="{'pos-padding': bodyLeftPadding}">
          <slot name="bodyLeft"></slot>
        </div>
      </transition>

      <!--content-right-->
      <transition name="slide-right">
        <div class="pos-card-body-right"
             :class="{'pos-padding': bodyRightPadding}"
             v-if="bodyRight && bodyRightShow">
          <slot name="bodyRight"></slot>
        </div>
      </transition>
    </div>

    <!--footer-->
    <div class="pos-card-footer" v-if="footer">
       <!--headerRight-->
      <div class="pos-card-header-item"
           v-if="footerLeft">
        <slot name="footerLeft"></slot>
      </div>

      <!--header content-->
      <div class="pos-card-header--content">
        <slot name="footer"></slot>
      </div>

      <!--headerLeft-->
      <div class="pos-card-header-item"
           v-if="footerRight">
        <slot name="footerRight"></slot>
      </div>
    </div>

  </div>
</template>

<script>
  export default {

    name: 'Card',

    props: {

      // header
      header:      {
        default: false,
        type:    Boolean
      },
      headerLeft:  {
        default: false,
        type:    Boolean
      },
      headerRight: {
        default: false,
        type:    Boolean
      },

      // footer
      footer:      {
        default: false,
        type:    Boolean
      },
      footerLeft:  {
        default: false,
        type:    Boolean
      },
      footerRight: {
        default: false,
        type:    Boolean
      },

      // Body
      body:             {
        type: String
      },
      bodyPadding:      {
        default: true,
        type:    Boolean
      },
      bodyLeft:         {
        default: false,
        type:    Boolean
      },
      bodyLeftPadding:  {
        default: true,
        type:    Boolean
      },
      bodyRight:        {
        default: false,
        type:    Boolean
      },
      bodyRightPadding: {
        default: true,
        type:    Boolean
      }
    },

    data () {
      return {
        bodyWidth:     null, // 540
        bodyLeftShow:  true,
        bodyRightShow: true
      }
    },

    watch: {
      bodyWidth () {

        // Показать right панель при ширине 1200
        //(this.bodyWidth > 1200 && this.bodyLeftShow) ? this.bodyRightShow = true : this.bodyRightShow = false
      }
    },

    // Отслеживание изменния ширины экрана
    mounted () {

      if (this.bodyRight || this.bodyLeft) {
        this.bodyWidth = this.$refs.body.offsetWidth
        window.addEventListener('resize', this.handleResize)
        if (this.bodyWidth <= 840 && this.bodyLeftShow) {
          this.bodyRightShow = false
        }
      }
    },

    beforeDestroy: function () {
      if (this.bodyRight || this.bodyLeft) {
        window.removeEventListener('resize', this.handleResize)
      }
    },

    methods: {

      bodyLeftToggle () {

        this.handleResize()
        this.bodyLeftShow = !this.bodyLeftShow
        //this.handleResize()
        setTimeout(() => {
          if (this.bodyWidth <= 700 && this.bodyRightShow) {
            this.bodyRightShow = false
          }
        }, 300)
      },

      bodyRightToggle () {

        this.handleResize()
        this.bodyRightShow = !this.bodyRightShow
        setTimeout(() => {
          if (this.bodyWidth <= 700 && this.bodyLeftShow) {
            this.bodyLeftShow = false
          }
        }, 300)
      },

      handleResize (el) {

        setTimeout(() => {
          this.bodyWidth = this.$refs.body.offsetWidth
        }, 300)

      }
    }
  }
</script>
