<script>
  import { onMount, createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher()

  export let src, expected

  onMount(() => {
    if (expected && window[expected]) return dispatch('loaded')

    const script = document.createElement('script')
    script.src = src
    script.addEventListener('load', () => dispatch('loaded'))
    script.addEventListener('error', () => dispatch('error'))
    document.head.appendChild(script)

    return () => script.remove()
  })
</script>
