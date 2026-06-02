import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

const BACKEND_DEV  = 'http://localhost:5000'
const BACKEND_PROD = 'http://plazas-backend-2024.eastus.azurecontainer.io:5000'

export default defineConfig(({ mode }) => ({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: mode === 'production' ? BACKEND_PROD : BACKEND_DEV,
        changeOrigin: true,
      }
    }
  },
  build: {
    // En build de producción, el frontend llama al backend de Azure directamente
    // El nginx.conf se encarga de hacer proxy de /api
  }
}))
