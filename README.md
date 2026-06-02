# 🏢 Sistema de Gestión de Plazas Comerciales

## 📋 Guion de Exposición del Proyecto

---

## 1. INTRODUCCIÓN (2 minutos)

### Presentación del Proyecto
Buenos días/tardes. Hoy presentaré un **Sistema Web de Gestión y Venta de Locales Comerciales** desarrollado para plazas comerciales del Estado de México.

### Problema que Resuelve
Las plazas comerciales necesitan una forma moderna y eficiente de:
- Mostrar la disponibilidad de locales en tiempo real
- Permitir que los clientes vean la ubicación exacta de cada local
- Procesar pagos de forma segura
- Gestionar transacciones y ventas

### Solución Propuesta
Una aplicación web completa con:
- Visualización interactiva mediante mapas satelitales
- Sistema de pagos integrado con PayPal
- Panel de administración para consultas
- Arquitectura escalable en la nube (Azure)

---

## 2. TECNOLOGÍAS UTILIZADAS (3 minutos)

### Frontend
- **React + Vite**: Framework moderno para interfaces rápidas y reactivas
- **React Router**: Navegación entre páginas
- **Leaflet.js**: Mapas interactivos con imágenes satelitales
- **Axios**: Comunicación con el backend
- **CSS3**: Diseño responsive con tema cyberpunk (negro con acentos morados)

### Backend
- **Node.js + Express**: Servidor API REST
- **PostgreSQL**: Base de datos relacional
- **PayPal SDK**: Integración de pagos
- **CORS**: Seguridad para peticiones cross-origin

### Infraestructura
- **Docker**: Contenedorización de aplicaciones
- **Azure Container Instances**: Despliegue en la nube
- **Azure Container Registry**: Almacenamiento de imágenes
- **Nginx**: Servidor web para el frontend

### Herramientas de Desarrollo
- **pgAdmin 4**: Administración de base de datos
- **Git**: Control de versiones
- **PowerShell**: Scripts de automatización

---

## 3. ARQUITECTURA DEL SISTEMA (4 minutos)

### Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────┐
│                         USUARIO                              │
│                    (Desktop / Móvil)                         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    FRONTEND (React)                          │
│  - Página principal con 5 plazas                            │
│  - Mapa interactivo con Leaflet                             │
│  - Formulario de compra/apartado                            │
│  - Integración con PayPal                                   │
│  Puerto: 80                                                  │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP/HTTPS
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   BACKEND (Node.js)                          │
│  - API REST con Express                                      │
│  - Rutas: /api/plazas, /api/locales, /api/transacciones    │
│  - Integración PayPal Sandbox                               │
│  - Validación de pagos                                      │
│  Puerto: 5000                                                │
└────────────────────────┬────────────────────────────────────┘
                         │ SQL
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              BASE DE DATOS (PostgreSQL)                      │
│  - Tablas: plazas, locales, clientes, transacciones        │
│  - 5 plazas con 106 locales totales                         │
│  - Estados: disponible, apartado, vendido                   │
│  Puerto: 5432                                                │
└─────────────────────────────────────────────────────────────┘
```

### Flujo de Datos

1. **Usuario** accede al frontend
2. **Frontend** solicita datos al backend
3. **Backend** consulta la base de datos
4. **Base de datos** retorna información
5. **Backend** procesa y envía respuesta
6. **Frontend** muestra datos en el mapa
7. **Usuario** selecciona un local y procede al pago
8. **PayPal** procesa el pago
9. **Backend** actualiza el estado del local

---

## 4. FUNCIONALIDADES PRINCIPALES (5 minutos)

### 4.1 Visualización de Plazas
- **5 plazas reales** del Estado de México:
  - Plaza Satélite (24 locales)
  - Plaza Las Américas (20 locales)
  - Plaza Coacalco (22 locales)
  - Plaza Ecatepec (20 locales)
  - Plaza Naucalpan (20 locales)
- Tarjetas interactivas con información de cada plaza
- Animación de hover con efectos visuales

### 4.2 Mapa Interactivo
- **Animación de vuelo**: Desde vista del Estado de México hasta la plaza seleccionada
- **Vista satelital**: Imágenes reales de las plazas
- **Locales como rectángulos**: Posicionados según coordenadas reales
- **Código de colores**:
  - 🟢 Verde: Disponible
  - 🔵 Azul: Apartado
  - 🔴 Rojo: Vendido
- **Tooltips**: Información al pasar el mouse (número, área, precio)
- **Optimización móvil**: Carga instantánea sin animación en dispositivos móviles

### 4.3 Sistema de Compra/Apartado
- **Modal interactivo** al hacer clic en un local
- **Formulario de contacto**: Nombre, email, teléfono
- **Dos opciones**:
  - **Compra**: Pago del 100% del precio
  - **Apartado**: Pago del 30% del precio
- **Validación de disponibilidad**: Solo locales disponibles pueden comprarse

### 4.4 Integración con PayPal
- **PayPal Sandbox**: Ambiente de pruebas
- **Flujo de pago**:
  1. Usuario llena formulario
  2. Se crea transacción en BD (estado: pendiente)
  3. Redirección a PayPal
  4. Usuario completa el pago
  5. PayPal confirma el pago
  6. Backend actualiza local (estado: vendido/apartado)
- **Conversión de moneda**: MXN a USD automática
- **Seguridad**: El local NO cambia de estado hasta que el pago se confirme

### 4.5 Panel de Administración (Consultas SQL)
- **15 consultas predefinidas** en pgAdmin:
  - Ver todas las transacciones
  - Estadísticas generales
  - Ingresos por plaza
  - Top 10 clientes
  - Transacciones del día/semana/mes
  - Locales más vendidos
  - Comparación compras vs apartados
  - Exportar a Excel
- **Consultas en tiempo real**
- **Filtros personalizables**

---

## 5. BASE DE DATOS (3 minutos)

### Esquema de Tablas

#### Tabla: plazas
```sql
- id (SERIAL PRIMARY KEY)
- nombre (VARCHAR)
- ubicacion (VARCHAR)
- descripcion (TEXT)
- lat, lng (FLOAT) - Coordenadas
- zoom_final (INT)
```

#### Tabla: locales
```sql
- id (SERIAL PRIMARY KEY)
- plaza_id (FK → plazas)
- numero (VARCHAR) - Ej: "L-001"
- area (DECIMAL) - m²
- precio (DECIMAL) - Precio de compra
- precio_apartado (DECIMAL) - 30% del precio
- estado (ENUM: disponible, apartado, vendido)
- lat_min, lat_max, lng_min, lng_max (FLOAT) - Bounds del rectángulo
```

#### Tabla: clientes
```sql
- id (SERIAL PRIMARY KEY)
- nombre (VARCHAR)
- email (VARCHAR UNIQUE)
- telefono (VARCHAR)
```

#### Tabla: transacciones
```sql
- id (SERIAL PRIMARY KEY)
- local_id (FK → locales)
- cliente_id (FK → clientes)
- tipo (ENUM: compra, apartado)
- monto (DECIMAL)
- estado_pago (ENUM: pendiente, completado, cancelado)
- paypal_order_id (VARCHAR)
- paypal_payment_id (VARCHAR)
- created_at, completed_at (TIMESTAMP)
```

### Datos Actuales
- **5 plazas** registradas
- **106 locales** totales
- **Coordenadas reales** de cada local
- **Precios diferenciados** por tamaño y ubicación

---

## 6. DESPLIEGUE EN AZURE (4 minutos)

### Recursos Creados

#### Azure Container Registry (ACR)
- **Nombre**: plazasacr2024.azurecr.io
- **Función**: Almacenar imágenes Docker
- **Imágenes**:
  - plazas-frontend:latest
  - plazas-backend:latest
  - postgres:15-alpine

#### Azure Container Instances (ACI)

**1. PostgreSQL Container**
- **Nombre**: plazas-postgres-2024
- **URL**: plazas-postgres-2024.eastus.azurecontainer.io:5432
- **Recursos**: 1 CPU, 1.5 GB RAM
- **Datos**: Persistentes en el contenedor

**2. Backend Container**
- **Nombre**: plazas-backend-2024
- **URL**: plazas-backend-2024.eastus.azurecontainer.io:5000
- **Recursos**: 1 CPU, 1 GB RAM
- **Variables de entorno**: Credenciales de BD y PayPal

**3. Frontend Container**
- **Nombre**: plazas-frontend-2024
- **URL**: plazas-frontend-2024.eastus.azurecontainer.io
- **Recursos**: 1 CPU, 1.5 GB RAM
- **Servidor**: Nginx

### Proceso de Despliegue

```powershell
# 1. Construir imágenes
docker build -t plazasacr2024.azurecr.io/plazas-backend ./backend
docker build -t plazasacr2024.azurecr.io/plazas-frontend ./frontend

# 2. Subir a ACR
docker push plazasacr2024.azurecr.io/plazas-backend
docker push plazasacr2024.azurecr.io/plazas-frontend

# 3. Crear contenedores en Azure
az container create --resource-group plazas-rg-eastus ...
```

### Scripts de Automatización
- **`redesplegar-frontend-movil.ps1`**: Redespliegue optimizado del frontend
- **`redeploy-backend-fix.ps1`**: Redespliegue del backend con correcciones
- **`desplegar-mejoras.ps1`**: Despliegue completo de mejoras

---

## 7. OPTIMIZACIONES IMPLEMENTADAS (3 minutos)

### 7.1 Corrección de Bug Crítico
**Problema**: Los locales cambiaban de estado antes de confirmar el pago en PayPal.

**Solución**:
- Transacción se crea en estado "pendiente"
- Local permanece "disponible" hasta confirmación de PayPal
- Solo cuando PayPal confirma, el local cambia a "vendido" o "apartado"
- Rollback automático si el pago falla

### 7.2 Optimización para Móviles
**Problema**: La aplicación no cargaba en dispositivos móviles (pantalla negra).

**Soluciones aplicadas**:
- **Efectos de fondo desactivados** en móvil (solo en desktop)
- **Animaciones desactivadas** (glow, pulse, vuelo del mapa)
- **Carga instantánea** del mapa en móviles
- **Estilos responsive** completos
- **Detección mejorada** de dispositivos móviles
- **Nginx optimizado** con compresión gzip y timeouts ajustados

**Resultado**: Carga en menos de 3 segundos en móviles.

### 7.3 Precios Diferenciados
- **Precio de compra**: 100% del valor del local
- **Precio de apartado**: 30% del valor del local
- Cálculo automático en el backend
- Visualización de ambos precios en el modal

### 7.4 Sistema de Consultas
- **15 consultas SQL** predefinidas para pgAdmin
- Consultas optimizadas con JOINs
- Exportables a Excel
- Filtros por fecha, estado, tipo, plaza

---

## 8. DEMOSTRACIÓN EN VIVO (5 minutos)

### 8.1 Página Principal
1. Mostrar las 5 plazas con sus tarjetas
2. Efecto hover en las tarjetas
3. Botón de "Panel de Administración"

### 8.2 Mapa Interactivo
1. Hacer clic en una plaza
2. Mostrar animación de vuelo (en desktop)
3. Visualizar locales con código de colores
4. Pasar el mouse sobre locales (tooltips)
5. Mostrar leyenda con contadores

### 8.3 Proceso de Compra
1. Hacer clic en un local disponible (verde)
2. Mostrar modal con información
3. Llenar formulario de contacto
4. Seleccionar "Compra" o "Apartado"
5. Ver diferencia de precios
6. Hacer clic en "Proceder al Pago con PayPal"
7. Redirección a PayPal Sandbox
8. Completar pago con cuenta de prueba
9. Redirección a página de éxito
10. Verificar cambio de estado del local

### 8.4 Consultas en pgAdmin
1. Abrir pgAdmin 4
2. Conectar a la base de datos Azure
3. Ejecutar consulta de transacciones
4. Mostrar estadísticas generales
5. Exportar resultados a Excel

### 8.5 Versión Móvil
1. Abrir en un teléfono
2. Mostrar carga rápida
3. Navegar por las plazas
4. Interactuar con el mapa
5. Demostrar responsive design

---

## 9. RETOS Y SOLUCIONES (3 minutos)

### Reto 1: Restricciones de Azure for Students
**Problema**: No se podía crear Azure SQL Database ni MySQL en ninguna región.

**Solución**: Desplegar PostgreSQL como contenedor en Azure Container Instances.

### Reto 2: Locales Atascados
**Problema**: Locales quedaban marcados como "apartado" sin pago completado.

**Solución**: 
- Implementar transacciones con estado "pendiente"
- Actualizar estado solo después de confirmación de PayPal
- Script SQL para liberar locales atascados

### Reto 3: Errores 422 de PayPal
**Problema**: Intentar capturar órdenes ya capturadas.

**Solución**:
- Verificar estado de transacción antes de capturar
- Detectar órdenes duplicadas
- Manejo de errores específicos de PayPal

### Reto 4: No Cargaba en Móviles
**Problema**: Pantalla negra en dispositivos móviles.

**Solución**:
- Desactivar efectos pesados (gradientes, animaciones)
- Optimizar carga del mapa
- Implementar estilos responsive
- Mejorar detección de dispositivos

### Reto 5: Moneda MXN en PayPal Sandbox
**Problema**: PayPal Sandbox tiene problemas con MXN.

**Solución**: Convertir automáticamente a USD (MXN / 20).

---

## 10. RESULTADOS Y MÉTRICAS (2 minutos)

### Funcionalidad
- ✅ **5 plazas** completamente funcionales
- ✅ **106 locales** con coordenadas reales
- ✅ **Sistema de pagos** integrado y probado
- ✅ **Responsive** en desktop, tablet y móvil
- ✅ **Desplegado en la nube** (Azure)

### Rendimiento
- ⚡ **Carga inicial**: < 3 segundos
- ⚡ **Carga del mapa**: Instantánea en móviles
- ⚡ **Consultas a BD**: < 100ms
- ⚡ **Procesamiento de pagos**: < 5 segundos

### Escalabilidad
- 📈 Arquitectura basada en contenedores
- 📈 Base de datos relacional escalable
- 📈 API REST stateless
- 📈 Frontend estático con CDN potencial

### Seguridad
- 🔒 Validación de datos en backend
- 🔒 Transacciones atómicas en BD
- 🔒 Integración segura con PayPal
- 🔒 HTTPS en producción (configurable)

---

## 11. TRABAJO FUTURO (2 minutos)

### Mejoras Técnicas
1. **Autenticación de usuarios**: Login para clientes y administradores
2. **Panel de admin web**: Interfaz gráfica en lugar de SQL
3. **Webhooks de PayPal**: Notificaciones automáticas de pagos
4. **Notificaciones por email**: Confirmaciones de compra
5. **Reserva temporal**: Bloquear local por 10 minutos durante el pago
6. **Historial de transacciones**: Para cada cliente
7. **Reportes en PDF**: Facturas y comprobantes

### Funcionalidades de Negocio
1. **Más plazas**: Expandir a otras ciudades
2. **Filtros avanzados**: Por precio, área, ubicación
3. **Comparador de locales**: Ver varios locales lado a lado
4. **Tour virtual**: Fotos 360° de los locales
5. **Chat en vivo**: Soporte en tiempo real
6. **Sistema de citas**: Para visitar locales físicamente
7. **Calculadora de ROI**: Retorno de inversión estimado

### Optimizaciones
1. **CDN**: Para assets estáticos
2. **Cache**: Redis para consultas frecuentes
3. **Load balancer**: Para alta disponibilidad
4. **Monitoreo**: Application Insights de Azure
5. **CI/CD**: Pipeline automatizado con GitHub Actions
6. **Tests automatizados**: Unit tests, integration tests, e2e tests

---

## 12. CONCLUSIONES (2 minutos)

### Logros del Proyecto
- ✅ Sistema completo y funcional de gestión de locales comerciales
- ✅ Integración exitosa con sistema de pagos (PayPal)
- ✅ Despliegue en la nube con Azure
- ✅ Optimizado para dispositivos móviles
- ✅ Base de datos robusta con 106 locales reales
- ✅ Interfaz moderna y atractiva

### Aprendizajes Técnicos
- Desarrollo full-stack con React y Node.js
- Integración de APIs de terceros (PayPal, Leaflet)
- Despliegue con Docker y Azure
- Optimización de rendimiento web
- Manejo de transacciones y estados
- Diseño responsive y mobile-first

### Valor del Proyecto
Este sistema permite a las plazas comerciales:
- **Modernizar** su proceso de venta
- **Automatizar** la gestión de locales
- **Visualizar** disponibilidad en tiempo real
- **Procesar pagos** de forma segura
- **Reducir** tiempos de venta
- **Mejorar** la experiencia del cliente

---

## 13. PREGUNTAS Y RESPUESTAS

### Preguntas Frecuentes Anticipadas

**P: ¿Por qué usar contenedores en lugar de App Service?**
R: Por las restricciones de Azure for Students y mayor control sobre la configuración.

**P: ¿Por qué PayPal y no Stripe u otro?**
R: PayPal es ampliamente usado en México y tiene buena documentación en español.

**P: ¿Cómo se actualizan los precios de los locales?**
R: Mediante consultas SQL directas en pgAdmin o se puede crear un panel de admin.

**P: ¿Qué pasa si dos personas intentan comprar el mismo local?**
R: El primero que complete el pago en PayPal se queda con el local. El segundo verá que ya no está disponible.

**P: ¿Cómo se manejan los reembolsos?**
R: Actualmente manual desde el dashboard de PayPal. Se puede automatizar con webhooks.

**P: ¿El sistema es escalable?**
R: Sí, la arquitectura basada en contenedores permite escalar horizontalmente cada componente.

---

## 14. RECURSOS Y ENLACES

### URLs del Proyecto
- **Frontend**: http://plazas-frontend-2024.eastus.azurecontainer.io
- **Backend API**: http://plazas-backend-2024.eastus.azurecontainer.io:5000
- **Base de Datos**: plazas-postgres-2024.eastus.azurecontainer.io:5432

### Repositorio
- **GitHub**: [Agregar URL del repositorio]

### Documentación
- **Consultas SQL**: `database/consultas-admin-pgadmin.sql`
- **Scripts de despliegue**: `*.ps1` en la raíz del proyecto

### Credenciales de Prueba (PayPal Sandbox)
- **Cuenta Business**: PruebaCarlos@example.com / carlos123
- **Cuenta Personal**: [Crear en PayPal Developer Dashboard]

---

## 15. AGRADECIMIENTOS

Gracias por su atención. Estoy disponible para responder cualquier pregunta o realizar una demostración más detallada de cualquier funcionalidad.

---

## ANEXO — Funcionalidades Agregadas (v2.0)

### Sistema de Autenticación
- Registro e inicio de sesión con JWT
- Roles: `admin` y `cliente`
- Contraseñas hasheadas con bcrypt
- Token persistente en localStorage
- Usuario admin por defecto: `admin@plazas.com` / `Admin123!`

### Dashboard de Administrador (`/admin-dashboard`)
- KPIs: disponibles, apartados, vendidos, ingresos totales
- Gráfica de pastel: estado de locales
- Gráfica de pastel: estado de pagos
- Gráfica de línea: ingresos por mes
- Gráfica de barras: locales por plaza
- Tabla de últimas transacciones con descarga de PDF

### Dashboard de Cliente (`/mi-cuenta`)
- Vista de locales comprados y apartados
- Para apartados: porcentaje pagado, saldo restante, días restantes, barra de progreso
- Descarga de comprobante PDF por transacción

### Opciones de Apartado
- 4 duraciones: 15, 30, 60 y 90 días
- Porcentaje variable: 15%, 25%, 35%, 50%
- Cálculo automático del monto a pagar y saldo restante

### Generación de PDF
- Comprobante con datos del cliente, local, plaza y transacción
- Políticas de compra y apartado incluidas
- Folio único, fecha, estado del pago
- Disponible para admin y para el cliente dueño de la transacción

### Migración de Base de Datos
- Ejecutar `database/migracion-auth.sql` en pgAdmin para activar todo

---

**Proyecto**: Sistema de Gestión de Plazas Comerciales  
**Tecnologías**: React, Node.js, PostgreSQL, Docker, Azure, Terraform  
**Fecha**: Mayo 2026  
**Estado**: ✅ Completado y Desplegado
