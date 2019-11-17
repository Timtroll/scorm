<template>
  <ul class="pos-list-menu"
      ref="listMenu">

    <li class="pos-list-menu-item"
        v-for="(item, index) in mainNav"
        :key="item.id"
        ref="items"
        :class="{'active' : item.id === active}">
      <a @click.prevent="click(item.id)"
         v-text="item.label"></a>
    </li>
    <li class="uk-flex-1 uk-text-right"
        v-if="mainNavDrop.length > 0">
      <button class="uk-button uk-button-link"
              type="button"
              :style="{width: dropIconWidth}">
        <img src="/img/icons/icon__nav.svg"
             uk-svg
             width="16"
             height="16">
      </button>
      <div uk-dropdown="mode: click; pos: bottom-right">
        <ul class="uk-nav uk-dropdown-nav">
          <li v-for="(item, index) in mainNavDrop"
              :class="{'active' : item.id === active}"
              :key="item.id">
            <a @click.prevent="click(item.id)"
               v-text="item.label"></a></li>
        </ul>
      </div>
    </li>

  </ul>
</template>

<script>
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
      this.width   = this.$refs.listMenu.clientWidth

      this.$nextTick(() => { })

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
        setTimeout(() => this.handleResize(), 500)
      },
      //
      resize () {
        setTimeout(() => this.handleResize(), 500)
      }
    },

    methods: {

      handleResize () {
        this.$nextTick(() => {
          if (window.innerWidth) {
            this.clientWidth = window.innerWidth
          }
          this.width = this.$refs.listMenu.clientWidth
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
        this.$emit('active', id)
      }
    }
  }
</script>
