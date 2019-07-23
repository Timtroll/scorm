<template>
  <svg xmlns="http://www.w3.org/2000/svg"
       :class="{'icon-hover-spin' : spin}"
       :width="size"
       :height="size"
       viewBox="0 0 26 26">
    <circle cx="13"
            cy="13"
            r="1.5"
            opacity=".6"
            fill="none"
            stroke="#fff"
            stroke-linecap="round"
            stroke-linejoin="round"></circle>
    <path d="M5.89,15.37A7.5,7.5,0,0,0,7.39,18l2.7-1.56a4.43,4.43,0,0,0,5.82,0L18.61,18a7.5,7.5,0,0,0,1.5-2.6l-2.69-1.55a4.44,4.44,0,0,0-2.92-5V5.65a7.57,7.57,0,0,0-3,0V8.78a4.44,4.44,0,0,0-2.92,5Z"
          fill="none"
          stroke="#fff"
          opacity=".6"
          class="inside"
          stroke-linecap="round"
          stroke-linejoin="round"></path>
    <circle cx="13"
            cy="13"
            r="7.5"
            fill="none"
            stroke="#fff"
            stroke-linecap="round"
            stroke-linejoin="round"></circle>
    <path d="M25.39,11.41l-2-.08A10.38,10.38,0,0,0,21.5,6.86l1.38-1.5a12.5,12.5,0,0,0-2.24-2.24L19.14,4.5a10.38,10.38,0,0,0-4.47-1.85l-.08-2A13.84,13.84,0,0,0,13,.5a13.84,13.84,0,0,0-1.59.11l-.08,2A10.38,10.38,0,0,0,6.86,4.5L5.36,3.12A12.5,12.5,0,0,0,3.12,5.36L4.5,6.86a10.38,10.38,0,0,0-1.85,4.47l-2,.08A13.84,13.84,0,0,0,.5,13a13.84,13.84,0,0,0,.11,1.59l2,.08A10.38,10.38,0,0,0,4.5,19.14l-1.38,1.5a12.5,12.5,0,0,0,2.24,2.24l1.5-1.38a10.38,10.38,0,0,0,4.47,1.85l.08,2A13.84,13.84,0,0,0,13,25.5a13.84,13.84,0,0,0,1.59-.11l.08-2a10.38,10.38,0,0,0,4.47-1.85l1.5,1.38a12.5,12.5,0,0,0,2.24-2.24l-1.38-1.5a10.38,10.38,0,0,0,1.85-4.47l2-.08A13.84,13.84,0,0,0,25.5,13,13.84,13.84,0,0,0,25.39,11.41Z"
          fill="none"
          stroke="#fff"
          class="outside"
          stroke-linecap="round"
          stroke-linejoin="round"></path>
  </svg>
</template>
<script>
  export default {

    name: 'IconSetting',

    props: {
      spin:  {
        type:    Boolean,
        default: false
      },
      size:  {
        type:    Number,
        default: 24
      },
      width: {
        type:    Number,
        default: 1
      }
    }

  }
</script>
<style lang="sass"
       scoped>
  .outside
    transform-origin: center center
    animation: outside 2s linear infinite
    animation-play-state: paused

  .inside
    transform-origin: center center
    animation: inside 2s linear infinite
    animation-play-state: paused

  a
    &:hover
      .outside,
      .inside
        animation-play-state: running

    @keyframes outside
      0%
        transform: rotate(0)
      100%
        transform: rotate(360deg)

    @keyframes inside
      0%
        transform: rotate(0)
      100%
        transform: rotate(-360deg)
</style>
