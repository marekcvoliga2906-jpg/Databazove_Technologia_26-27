<script setup>
    const props = defineProps(["title","text"])
    const emit = defineEmits(['enlarge-text'])
</script>

<template>
<div>
    <h1>{{title}}</h1>
    <p>{{text}}</p>
    <button @click="$emit('enlarge-text')">
        Enlarge text</button>
</div>
</template>

<style scoped></style>
