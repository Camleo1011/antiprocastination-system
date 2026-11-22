import { fileURLToPath } from 'node:url'
import { defineConfig } from 'vite'

export default defineConfig({
  build: {
    rolldownOptions: {
      input: {
        home: fileURLToPath(new URL('./index.html', import.meta.url)),
        recover: fileURLToPath(new URL('./recover/index.html', import.meta.url)),
      },
    },
  },
})
