# Imagen base
FROM node:18-alpine

WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias de producción
RUN npm ci --only=production

# Copiar código fuente
COPY . .

# Exponer puerto
EXPOSE 5000

# Variables de entorno por defecto (se sobrescriben en Azure)
ENV NODE_ENV=production

# Iniciar aplicación
CMD ["node", "server.js"]
