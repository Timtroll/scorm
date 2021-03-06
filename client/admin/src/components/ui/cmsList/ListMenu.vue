<template>
  <ul class="pos-list-menu"
      ref="listMenu">

    <li class="pos-list-menu-item"
        v-for="(item, index) in mainNav"
        :key="item.id"
        ref="items"
        :class="{'active' : item.id === active}">
      <a @click.prevent="click(item.id)"
         v-text="item.label"/>
    </li>
    <li class="uk-text-right uk-flex-1 "
        v-if="mainNavDrop.length > 0">
      <button class="uk-button uk-button-link"
              type="button"
              :style="{width: dropIconWidth}">
        <img src="/img/icons/icon__dots-v.svg"
             uk-svg
             class="uk-button-icon-fix"
             width="16"
             height="16">
      </button>

      <div uk-dropdown="mode: click; pos: bottom-right">
        <ul class="uk-nav uk-dropdown-nav">
          <li v-for="(item, index) in mainNavDrop"
              :class="{'active' : item.id === active}"
              :key="item.id">
            <a @click.prevent="click(item.id)"
               v-text="item.label"/>
          </li>
        </ul>
      </div>
    </li>

  </ul>
</template>

<script>
  import ResizeObserver from 'resize-observer-polyfill'
  import {clone} from '../../../store/methods'

  export default {
    name: 'ListMenu',

    props: {

      nav: {
        type:     Array,
        required: true
      },

      active: {
        type: Number
      },

      resize: {
        type: Boolean
      }
    },

    data () {
      return {
        width:         0,
        widthChanged:  0,
        allNav:        [],
        mainNav:       [],
        mainNavDrop:   [],
        dropIconWidth: 60,
        clientWidth:   0
      }
    },

    async mounted () {

      if (this.nav) {
        this.allNav = clone(this.nav)
        this.allNav.forEach((item, index) => {
          item.el       = 'listMenuItem_' + index
          item.dropdown = false
        })
      }
      this.mainNav = clone(this.allNav)
      //this.width   = this.$refs.listMenu.clientWidth

      const observer = new ResizeObserver(entries => {
        entries.forEach(entry => {
          const cr   = entry.contentRect
          this.width = cr.width.toFixed(0)
        })
      })

      observer.observe(this.$refs.listMenu)

      await this.menuWidth()
      await this.menuIsDrop()

      this.clientWidth = window.innerWidth
      window.addEventListener('resize', this.handleResize)

    },

    beforeDestroy: function () {
      if (this.bodyRight || this.bodyLeft) {
        window.removeEventListener('resize', this.handleResize)
      }
    },

    watch: {

      clientWidth () {
        setTimeout(() => this.handleResize(), 300)
      },

      //
      resize () {
        setTimeout(() => this.handleResize(), 300)
      }
    },

    methods: {

      handleResize () {
        this.$nextTick(() => {
          if (window.innerWidth) {
            this.clientWidth = window.innerWidth
          }
          //this.width = this.$refs.listMenu.clientWidth
          this.menuIsDrop()
        })
      },

      menuWidth () {

        this.$nextTick(() => {
          if (this.mainNav && this.mainNav.length > 0) { }

          this.mainNav.forEach((item, index) => {
            item.width = this.$refs.items[index].clientWidth
          })

          this.allNav = this.mainNav
        })

      },

      menuIsDrop () {

        let menuVisible = 0

        this.$nextTick(() => {

          this.allNav.forEach((item) => {
            menuVisible   = menuVisible + item.width
            item.dropdown = menuVisible > this.width - this.dropIconWidth
          })

          this.mainNavDrop = this.allNav.filter(item => item.dropdown === true)
          this.mainNav     = this.allNav.filter(item => item.dropdown === false)
        })
      },

      click (id) {
        this.$emit('active-id', id)
      }
    }
  }
</script>
