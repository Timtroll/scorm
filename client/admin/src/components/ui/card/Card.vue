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
         v-if="bodyRightToggleShow"
         :class="{'uk-text-danger' : bodyRightShow}"
         @click.prevent="bodyRightToggle">
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
        <slot name="body"></slot>
      </div>

      <!--content-left-->
      <transition name="slide-left">
        <div class="pos-card-body-left"
             ref="bodyLeft"
             v-show="bodyLeft && bodyLeftShow"
             :class="{'pos-padding': bodyLeftPadding}">
          <slot name="bodyLeft"></slot>
        </div>
      </transition>

    </div>

    <!--footer-->
    <div class="pos-card-footer"
         v-if="footer">
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

    <!--content-right-->
    <transition name="slide-right">
      <div class="pos-card-body-right"
           v-if="bodyRight && bodyRightShow">

        <div class="pos-card-body pos-padding">
          <slot name="bodyRight"></slot>
        </div>
        <div class="pos-card-footer">
          <slot name="bodyRightFooter"></slot>
        </div>
      </div>
    </transition>
  </div>
</template>

<script>

  const bodyMinSize = 840
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

      bodyPadding:         {
        default: true,
        type:    Boolean
      },
      bodyLeft:            {
        default: false,
        type:    Boolean
      },
      bodyLeftPadding:     {
        default: true,
        type:    Boolean
      },
      bodyLeftToggleShow:  {
        default: true,
        type:    Boolean
      },
      bodyRight:           {
        default: false,
        type:    Boolean
      },
      bodyRightPadding:    {
        default: true,
        type:    Boolean
      },
      bodyRightToggleShow: {
        default: false,
        type:    Boolean
      },
      bodyRightShow:       {
        default: false,
        type:    Boolean
      }
    },

    data () {
      return {
        bodyWidth:     null, // 540
        bodyLeftWidth: null, // 540
        bodyLeftShow:  true
        //bodyRightShow: true
      }
    },

    // Отслеживание изменния ширины экрана
    mounted () {

      if (this.bodyRight || this.bodyLeft) {
        this.bodyWidth = this.$refs.body.offsetWidth
        window.addEventListener('resize', this.handleResize)
        if (this.bodyWidth <= bodyMinSize && this.bodyLeftShow) {
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

      // показать / скрыть левую панель
      bodyLeftToggle () {

        this.handleResize()
        this.bodyLeftShow = !this.bodyLeftShow

        setTimeout(() => {
          if (this.bodyWidth <= bodyMinSize && this.bodyRightShow) {
            this.bodyRightShow = false
          }
        }, 300)
      },

      // показать / скрыть правую панель
      bodyRightToggle () {

        this.handleResize()
        this.bodyRightShow = !this.bodyRightShow

        setTimeout(() => {
          if (this.bodyWidth <= bodyMinSize && this.bodyLeftShow) {
            this.bodyLeftShow = false
          }
        }, 300)
      },

      handleResize () {
        setTimeout(() => {
          this.bodyWidth = this.$refs.body.offsetWidth
        }, 300)

      }
    }
  }
</script>
