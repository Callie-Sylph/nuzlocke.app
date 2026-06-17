import preprocess from 'svelte-preprocess';
import node from '@sveltejs/adapter-node';

export default {
  kit: {
    adapter: node(),
    prerender: {
      // Self-hosted: don't fail the build on stale links / missing static
      // assets (e.g. the upstream social-share image). Warn instead.
      handleHttpError: 'warn',
      handleMissingId: 'warn'
    }
  },

  preprocess: [
    preprocess({
      postcss: true
    })
  ]
};
