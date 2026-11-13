<script setup>
import { RouterLink, RouterView } from 'vue-router'
</script>
<template>
  <header>
    <nav id="nav">
      <RouterLink to="/">Home</RouterLink>
      <RouterLink to="/">Brazil</RouterLink>
      <RouterLink to="/">Panama</RouterLink>
      <RouterLink to="/">Jamaica</RouterLink>
    </nav>
  </header>
  <div class="container">
    <RouterView />
  </div>
</template>
