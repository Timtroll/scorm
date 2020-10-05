<template>
  <svg :class="status"
       xmlns="http://www.w3.org/2000/svg"
       viewBox="0 0 48 48"
       :width="size"
       :height="size">
    <g class="female"
       :class="status">
      <rect x="14"
            y="36"
            width="20"
            height="6"
            :stroke-width="strokeWidth"
            :stroke="color"
            stroke-linecap="round"
            stroke-linejoin="round"
            fill="none"/>
      <line x1="24"
            y1="42"
            x2="24"
            y2="48"
            fill="none"
            :stroke="color"
            stroke-linecap="round"
            stroke-linejoin="round"
            :stroke-width="strokeWidth"/>
    </g>
    <g class="male"
       :class="status">
      <path d="M24,8h0A10,10,0,0,1,34,18v2a0,0,0,0,1,0,0H14a0,0,0,0,1,0,0V18A10,10,0,0,1,24,8Z"
            fill="none"
            :stroke="color"
            stroke-linecap="round"
            stroke-linejoin="round"
            :stroke-width="strokeWidth"/>
      <line x1="24"
            y1="-8"
            x2="24"
            y2="8"
            fill="none"
            :stroke="color"
            stroke-linecap="round"
            stroke-linejoin="round"
            :stroke-width="strokeWidth"/>
      <line x1="18"
            y1="20"
            x2="18"
            y2="28"
            fill="none"
            :stroke="color"
            stroke-linecap="round"
            stroke-linejoin="round"
            :stroke-width="strokeWidth"/>
      <line x1="30"
            y1="20"
            x2="30"
            y2="28"
            fill="none"
            :stroke="color"
            stroke-linecap="round"
            stroke-linejoin="round"
            :stroke-width="strokeWidth"/>
    </g>
  </svg>
</template>

<script>
export default {
  name: 'IconConnect',

  props: {

    size: {
      default: 32,
      type:    Number
    },

    status: {
      default: 'progress', // progress, success, error
      type:    String
    },

    colorSuccess: {
      default: '#81b752',
      type:    String
    },

    colorProgress: {
      default: '#3a8fd0',
      type:    String
    },

    colorError: {
      default: '#e24f45',
      type:    String
    }

  },

  data () {
    return {}
  },

  computed: {

    strokeWidth () {
      if (this.size <= 24) {
        return 4
      }
      else if (this.size > 24 && this.size <= 32) {
        return 3
      }
      else if (this.size > 32 && this.size <= 48) {
        return 2
      }
      else {
        return 1.5
      }
    },

    color () {
      switch (this.status) {
        case 'progress':
          return this.colorProgress
        case 'success':
          return this.colorSuccess
        case 'error':
          return this.colorError
        default:
          return 'currentColor'
      }
    }
  }
}
</script>

<style lang="sass">
svg
  transition: transform .3s ease

  &.error
    transform: rotate(180deg)

  &.progress
    transform: rotate(45deg)

.male,
.female
  will-change: transform
  transform-origin: center center

.male
  &.progress
    animation: progressMale .6s ease-out infinite

  &.success
    transform: translateY(8px)

.female
  &.progress
    animation: progressFemale .6s ease-in infinite

  &.success
    transform: translateY(8px)

@keyframes progressMale
  0%
    transform: translateY(0)
  50%
    transform: translateY(5px)
  100%
    transform: translateY(0)

@keyframes progressFemale
  0%
    transform: translateY(0)
  50%
    transform: translateY(-4px)
  100%
    transform: translateY(0)

</style>
