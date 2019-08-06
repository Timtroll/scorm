<template>
  <div class="pos-card">

    <!--header-->
    <div class="pos-card-header"
         :class="{
         'pos-bgr-default' : headerBgrDefault,
         'pos-header-large' : headerLarge}"
         v-if="header">

      <!-- toggle left body panel-->
      <a class="pos-card-header-item link"
         v-if="bodyLeftToggleShow"
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

      <!-- toggle right body panel-->
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

        <div class="pos-card-body">
          <slot name="bodyRight"></slot>
        </div>
        <div class="pos-card-footer">
          <slot name="bodyRightFooter"></slot>
        </div>
      </div>
    </transition>

    <transition name="fade">
      <div class="pos-card-loader"
           v-if="loader">
        <div>
          <Loader :width="40"
                  :height="40"></Loader>
          <div class="uk-margin-small-top"
               v-text="$t('actions.loading')"></div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script>
  import Loader from '../icons/Loader'

  const bodyMinSize = 840

  export default {

    name:       'Card',
    components: {Loader},
    props:      {

      // header
      header:           {
        default: false,
        type:    Boolean
      },
      headerLarge:      {
        default: false,
        type:    Boolean
      },
      headerBgrDefault: {
        default: false,
        type:    Boolean
      },
      headerLeft:       {
        default: false,
        type:    Boolean
      },
      headerRight:      {
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

      //body
      bodyPadding: {
        default: true,
        type:    Boolean
      },

      // bodyLeft
      bodyLeft:            {
        default: false,
        type:    Boolean
      },
      bodyLeftPadding:     {
        default: true,
        type:    Boolean
      },
      bodyLeftToggleShow:  {
        default: false,
        type:    Boolean
      },
      bodyLeftActionEvent: {
        default: false,
        type:    Boolean
      },

      // bodyRight
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
      },

      // loader
      loader: {
        default: true,
        type:    Boolean
      }
    },

    data () {
      return {
        bodyWidth:     null, // 540
        bodyLeftWidth: null, // 540
        bodyLeftShow:  true
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

    watch: {

      //
      bodyLeftActionEvent () {

        console.log(this.bodyWidth)
        //this.bodyLeftShow = false

        if (this.bodyWidth <= bodyMinSize && this.bodyLeftShow) {
          this.bodyLeftShow = false
        }
      }
    },

    computed: {},

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

      handleResize () {

        setTimeout(() => {
          this.bodyWidth = this.$refs.body.offsetWidth
        }, 300)

      }
    }
  }
</script>
