<script setup>
import { RouterLink, RouterView } from 'vue-router'
</script>
<template>
  <header>
    <nav id="nav">
      <RouterLink to="/">Home</RouterLink>
      <RouterLink to="/about">About</RouterLink>
    </nav>
  </header>
  <div class="container">
    <RouterView />
  </div>
</template>
