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
        <slot name="headerLeft"></slot>
      </div>

      <!--header settings-->
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

    <!--Body-->
    <div class="pos-card-body">

      <!--body-middle-->
      <div class="pos-card-body-middle"
           ref="body"
           :class="{'pos-padding': bodyPadding}">

        <slot name="body"></slot>

      </div>

      <!--body-left-->
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

      <!--footer Left-->
      <div class="pos-card-header-item"
           v-if="footerLeft">

        <slot name="footerLeft"></slot>
      </div>

      <!--header settings-->
      <div class="pos-card-header--content">
        <slot name="footer"></slot>
      </div>

      <!--footer Right-->
      <div class="pos-card-header-item"
           v-if="footerRight">

        <slot name="footerRight"></slot>
      </div>
    </div>

    <!--settings-right-->
    <transition name="slide-right">
      <div class="pos-card-body-right"
           v-if="bodyRightShow"
           :class="{'large' : rightPanelSize}">

        <slot name="bodyRight"></slot>

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
      <div class="pos-card-loader"
           v-else-if="loader === 'error'">
        <div>
          <IconBug :width="40"
                   :height="40"></IconBug>
            <div class="uk-margin-small-top"
                 v-text="$t('actions.requestError')"></div>
        </div>
      </div>
    </transition>

  </div>
</template>

<script>
  const bodyMinSize = 960

  export default {

    name: 'Card',

    components: {
      Loader:  () => import('../icons/Loader'),
      IconBug: () => import('../icons/IconBug')
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
        default: '',
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

      if (this.bodyRight || this.bodyLeft) {

        this.bodyWidth     = this.$refs.body.offsetWidth
        this.bodyLeftWidth = this.$refs.bodyLeft.offsetWidth

        window.addEventListener('resize', this.handleResize)

        if (this.bodyWidth <= bodyMinSize && this.leftToggleState) {
          this.$store.commit('editPanel_show', false)
        }
      }
    },

    watch: {

      //
      RightToggleState () {

        if (this.bodyWidth <= bodyMinSize && this.leftToggleState) {
          this.$store.commit('editPanel_show', false)
        }
      },

      cardLeftClickAction () {
        if (this.bodyWidth <= bodyMinSize && this.leftToggleState) {
          this.$store.commit('card_left_show', false)
        }
      }
    },

    computed: {

      RightToggleState () {
        setTimeout(() => {this.handleResize()}, 300)
        return this.$store.getters.pageTableRowShow
      },

      rightPanelSize () {
        return this.$store.getters.editPanel_large
      },

      leftToggleState () {
        setTimeout(() => {this.handleResize()}, 300)
        return this.$store.getters.cardLeftState
      },

      cardLeftClickAction () {
        return this.$store.getters.cardLeftClickAction
      }

    },

    beforeDestroy: function () {
      if (this.bodyRight || this.bodyLeft) {
        window.removeEventListener('resize', this.handleResize)
      }
    },

    methods: {

      handleResize () {
        setTimeout(() => {this.bodyWidth = this.$refs.body.offsetWidth}, 300)
      }
    }
  }
</script>
