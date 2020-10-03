<template>
  <div class="pos-card">

    <!--header-->
    <div class="pos-card-header"
         :class="{
         'pos-bgr-default' : headerBgrDefault,
         'pos-header-large' : headerLarge,
         'pos-header-small' : headerSmall,
         'pos-header-padding-none' : headerPaddingNone
         }"
         v-if="header">

      <!--headerLeft-->
      <div class="pos-card-header-item"
           v-if="headerLeft">
        <slot name="headerLeft"/>
      </div>

      <!--header-->
      <div class="pos-card-header--content">
        <slot name="header"/>
      </div>

      <!--headerRight-->
      <div class="pos-card-header-item"
           v-if="headerRight">
        <slot name="headerRight"/>
      </div>

    </div>

    <!--Body-->
    <div class="pos-card-body"
         v-touch:swipe="swipe">

      <!--body-middle-->
      <div class="pos-card-body-middle"
           ref="body"
           :class="{'pos-padding': bodyPadding}">

        <slot name="body"/>

      </div>

      <!--body-left-->
      <transition name="slide-left">
        <div class="pos-card-body-left"
             ref="bodyLeft"
             v-show="bodyLeft && cardLeftState"
             :class="{'pos-padding': bodyLeftPadding}">
          <slot name="bodyLeft"/>
        </div>
      </transition>

    </div>

    <!--footer-->
    <div class="pos-card-footer"
         v-if="footer">

      <!--footer Left-->
      <div class="pos-card-header-item"
           v-if="footerLeft">

        <slot name="footerLeft"/>
      </div>

      <!--header settings-->
      <div class="pos-card-header--content">
        <slot name="footer"/>
      </div>

      <!--footer Right-->
      <div class="pos-card-header-item"
           v-if="footerRight">

        <slot name="footerRight"/>
      </div>
    </div>

    <!--settings-right-->
    <transition name="slide-right">
      <div class="pos-card-body-right"
           v-if="bodyRightShow"
           :class="{'large' : rightPanelSize}">

        <slot name="bodyRight"/>

      </div>
    </transition>

    <!--loading-->
    <transition name="fade">
      <div class="pos-card-loader"
           v-if="loader === 'loading'">
        <div>
          <Loader :width="40"
                  :height="40"/>
          <div class="uk-margin-small-top"
               v-text="$t('actions.loading')"></div>
        </div>
      </div>

      <!--error-->
      <div class="pos-card-loader"
           v-else-if="loader === 'error'">
        <div>
          <IconBug :width="60"
                   :height="60"/>
          <div class="uk-margin-small-top"
               v-html="$t('actions.requestError')"></div>
        </div>
      </div>
    </transition>

  </div>
</template>

<script>
  const bodyMinSize = 960

  import ResizeObserver from 'resize-observer-polyfill'

  export default {

    name: 'Card',

    components: {
      Loader:  () => import(/* webpackChunkName: "Loader" */ '../icons/Loader'),
      IconBug: () => import(/* webpackChunkName: "IconBug" */ '../icons/IconBug')
    },

    props: {

      // header
      header:            {
        default: false,
        type:    Boolean
      },
      headerLarge:       {
        default: false,
        type:    Boolean
      },
      headerSmall:       {
        default: false,
        type:    Boolean
      },
      headerPaddingNone: {
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
        default: '', // [loading, success, error]
        type:    String
      }
    },

    data () {
      return {
        bodyWidth:     null, // 540
        bodyLeftWidth: null // 540
      }
    },

    // Отслеживание изменния ширины экрана
    mounted () {

      const observer = new ResizeObserver(entries => {
        entries.forEach(entry => {
          const cr       = entry.contentRect
          this.bodyWidth = Number(cr.width.toFixed(0))
        })
      })

      if (this.$refs.body) {
        observer.observe(this.$refs.body)
      }

      if (this.bodyRight || this.bodyLeft) {

        //this.bodyWidth     = this.$refs.body.offsetWidth
        this.bodyLeftWidth = this.$refs.bodyLeft.offsetWidth

        window.addEventListener('resize', this.handleResize)

        if (this.bodyWidth <= bodyMinSize && this.cardLeftState) {
          this.$store.commit('card_right_show', false)
        }
        if (this.$route.meta.root) {
          this.$store.commit('card_left_show', true)
        }
      }
    },

    beforeRouteEnter (to, from, next) {
      next(vm => {
        if (vm.$route.meta.root) {
          console.log('next')
          vm.$store.commit('card_left_show', true)
        }
      })
    },

    watch: {

      //
      cardRightState () {

        if (this.cardRightState) {
          if (this.bodyWidth <= bodyMinSize && this.cardLeftState) {
            if (!this.$route.meta.root) {
              this.$store.commit('card_left_show', false)
              //this.$store.commit('card_right_show', false)
            }
          }
        }

      },

      //cardLeftState () {
      //
      //  if (this.cardRightState) {
      //    if (this.bodyWidth <= bodyMinSize && this.cardRightState) {
      //      //this.$store.commit('card_left_show', false)
      //      this.$store.commit('card_right_show', false)
      //    }
      //  }
      //
      //},

      cardLeftClickAction () {
        if (this.bodyWidth <= bodyMinSize) {
          if (this.cardLeftState) {
            this.$store.commit('card_left_show', false)
          }

        }
      }
    },

    computed: {

      cardRightState () {
        setTimeout(() => {this.handleResize()}, 300)
        return this.$store.getters.cardRightState
      },

      rightPanelSize () {
        return this.$store.getters.editPanel_large
      },

      cardLeftState () {
        setTimeout(() => {
          this.handleResize()
        }, 300)
        return this.$store.getters.cardLeftState
      },

      cardLeftClickAction () {
        return this.$store.getters.cardLeftClickAction
      }

    },

    beforeDestroy: function () {

      window.removeEventListener('resize', this.handleResize)
      //if (this.bodyRight || this.bodyLeft) {}
    },

    methods: {

      swipe (direction) {
        if (direction === 'right') {
          this.$store.commit('card_left_show', true)
        }
      },

      handleResize () {
        setTimeout(() => {
          this.bodyWidth = this.$refs.body.offsetWidth
        }, 300)
      }
    }
  }
</script>
