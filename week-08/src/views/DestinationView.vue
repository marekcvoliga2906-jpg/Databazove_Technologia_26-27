<script setup>
import dataDestinations from '../data.json'
const destinations = dataDestinations.destinations
const props = defineProps({
  slug: {
    type: String, required: true
  },
  experienceSlug: {
    type: String, required: true
  }
});
</script>   

<template>
<h1>SDA</h1>
</template>