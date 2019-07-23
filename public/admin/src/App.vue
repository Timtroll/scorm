<template>
  <div id="app">
    <transition name="rotate"
                mode="out-in"
                appear>
      <router-view/>
    </transition>
  </div>
</template>
