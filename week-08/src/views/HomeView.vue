<script setup>
import dataDestinations from '../data.json'
const destinations = dataDestinations.destinations
</script>
<template>
  <div class="home">
    <h1>All Destinations</h1>
    <div class="destinations">
      <div v-for="destination in destinations">
        <h2>{{ destination.name }}</h2>
        <img :src="'/images/' + destination.image" :alt="destination.name">
      </div>
    </div>
  </div>
</template>
