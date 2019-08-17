<template>
  <div class="pos-card">

    <!--header-->
    <div class="pos-card-header"
         :class="{
         'pos-bgr-default' : headerBgrDefault,
         'pos-header-large' : headerLarge}"
         v-if="header">

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
             v-show="bodyLeft && leftToggleState"
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
           v-if="bodyRightShow"
           :class="{'large' : rightPanelSize}">

        <!--pos-card right header-->
        <div class="pos-card-header">

          <!--headerLeft-->

          <a class="pos-card-header-item link"
             :class="{'uk-text-danger' : rightPanelSize}"
             @click.prevent="rightPanelSize = !rightPanelSize">

            <img src="/img/icons/icon__expand.svg"
                 uk-svg
                 width="20"
                 height="20"
                 v-if="!rightPanelSize">

            <img src="/img/icons/icon__collapse.svg"
                 uk-svg
                 width="20"
                 height="20"
                 v-else>
          </a>

          <!--header content-->
          <div class="pos-card-header--content"
               v-text="bodyRightHeaderTitle"></div>

          <!--headerRight-->
          <a class="pos-card-header-item uk-text-danger link"
             @click.prevent="close">
            <img src="/img/icons/icon__close.svg"
                 uk-svg
                 width="16"
                 height="16">
          </a>

        </div>

        <!--body Right-->
        <div class="pos-card-body">
          <slot name="bodyRight"></slot>
        </div>

        <!--body Right Footer-->
        <div class="pos-card-footer">
          <slot name="bodyRightFooter"></slot>
        </div>

      </div>
    </transition>

    <!--loading-->
    <transition name="fade">
      <div class="pos-card-loader"
           v-if="loader === 'loading'">
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

  const bodyMinSize = 960

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
      bodyLeft:        {
        default: false,
        type:    Boolean
      },
      bodyLeftPadding: {
        default: true,
        type:    Boolean
      },

      bodyLeftActionEvent: {
        default: false,
        type:    Boolean
      },

      // bodyRight
      bodyRight: {
        default: false,
        type:    Boolean
      },

      bodyRightHeaderTitle: {
        default: null,
        type:    String
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
        default: '',
        type:    String
      }
    },

    data () {
      return {
        bodyWidth:      null, // 540
        bodyLeftWidth:  null, // 540
        rightPanelSize: true
      }
    },

    // Отслеживание изменния ширины экрана
    mounted () {

      if (this.bodyRight || this.bodyLeft) {
        this.bodyWidth     = this.$refs.body.offsetWidth
        this.bodyLeftWidth = this.$refs.bodyLeft.offsetWidth
        window.addEventListener('resize', this.handleResize)
        if (this.bodyWidth <= bodyMinSize && this.leftToggleState) {
          this.$store.commit('cms_table_row_show', false)
        }
      }
    },

    watch: {

      //
      RightToggleState () {

        if (this.bodyWidth <= bodyMinSize && this.leftToggleState) {
          this.$store.commit('card_left_state', false)
        }
      }
    },

    computed: {

      RightToggleState () {
        setTimeout(() => {this.handleResize()}, 300)
        return this.$store.getters.pageTableRowShow
      },

      leftToggleState () {
        setTimeout(() => {this.handleResize()}, 300)
        return this.$store.getters.cardLeftState
      }
    },

    beforeDestroy: function () {
      if (this.bodyRight || this.bodyLeft) {
        window.removeEventListener('resize', this.handleResize)
      }
    },

    methods: {

      close () {
        this.$store.commit('cms_table_row_show', false)
      },

      leftToggleAction () {
        this.$store.commit('setNavbarLeftActionState', !this.leftToggleState)
      },

      handleResize () {

        setTimeout(() => {this.bodyWidth = this.$refs.body.offsetWidth}, 300)

      }
    }
  }
</script>
