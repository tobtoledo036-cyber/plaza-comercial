# 🎯 INSTRUCCIONES FINALES - Sistema de Autenticación

## ✅ Estado Actual

**Backend y Frontend desplegados exitosamente en Azure**

- ✅ Backend construido y subido a ACR
- ✅ Frontend construido y subido a ACR  
- ✅ Contenedores reiniciados en Azure

---

## 📋 PASO FINAL: Ejecutar Migración SQL

**IMPORTANTE**: Debes ejecutar la migración SQL en la base de datos de Azure para que el sistema funcione.

### Pasos en pgAdmin:

1. **Abre pgAdmin 4**

2. **Conéctate a tu servidor de Azure**:
   - En el panel izquierdo, expande: `Servers > Plazas Azure`
   - Si no tienes "Plazas Azure" registrado, créalo con:
     - Host: `plazas-postgres-2024.eastus.azurecontainer.io`
     - Port: `5432`
     - Database: `plazas_db`
     - Username: `plazasadmin`
     - Password: `TuPassword123!`

3. **Abre Query Tool**:
   - Expande: `Databases > plazas_db`
   - Click derecho en `plazas_db`
   - Selecciona: `Query Tool`

4. **Carga el archivo SQL**:
   - En Query Tool, click en el icono 📁 (Open File)
   - Navega a: `C:\Users\marco\Downloads\plaza-comercial\database\migracion-auth.sql`
   - Abre el archivo

5. **Ejecuta la migración**:
   - Click en el botón ▶️ (Execute/Refresh) o presiona `F5`
   - Verifica que veas: `Query returned successfully`

### ¿Qué hace la migración?

- ✅ Crea tabla `usuarios` para login/registro
- ✅ Inserta usuario admin: `admin@plazas.com` / `Admin123!`
- ✅ Agrega columnas de apartado a `transacciones`
- ✅ Agrega columna `precio_apartado` a `locales`
- ✅ Crea índices para optimizar consultas

---

## 🌐 URLs de la Aplicación

- **Frontend**: http://plazas-frontend-2024.eastus.azurecontainer.io
- **Backend**: http://plazas-backend-2024.eastus.azurecontainer.io:5000

---

## 👤 Credenciales de Administrador

```
Email:    admin@plazas.com
Password: Admin123!
```

---

## 🧪 Cómo Probar el Sistema

### Para Administrador:

1. Abre el frontend en tu navegador
2. Click en **"Iniciar Sesión"** (esquina superior derecha)
3. Ingresa las credenciales de admin
4. Verás el **Dashboard de Administrador** con:
   - 📊 Gráfica de distribución de locales (disponibles/vendidos/apartados)
   - 💰 Gráfica de ingresos por plaza
   - 📈 Tabla de transacciones recientes
   - 📉 Gráfica de tendencia de ventas

### Para Clientes:

1. Click en **"Registrarse"**
2. Crea una cuenta nueva con:
   - Nombre completo
   - Email
   - Contraseña (mínimo 6 caracteres)
   - Teléfono (opcional)
3. Navega por las plazas y selecciona un local
4. Elige entre **Comprar** o **Apartar**:
   - **Comprar**: Paga el 100% del precio
   - **Apartar**: Elige duración y paga porcentaje:
     - 15 días → 15% del precio
     - 30 días → 25% del precio
     - 60 días → 35% del precio
     - 90 días → 50% del precio
5. Completa el pago con PayPal Sandbox
6. Ve a **"Mi Cuenta"** para ver tus locales
7. Descarga el **PDF** con los detalles de tu transacción

---

## 📊 Nuevas Funcionalidades Implementadas

### 🔐 Sistema de Autenticación
- Login y registro de usuarios
- Autenticación JWT con tokens de 7 días
- Roles: `admin` y `cliente`
- Protección de rutas privadas

### 📈 Dashboard de Administrador
- 4 gráficas interactivas con Recharts:
  1. **Distribución de locales** (Pie Chart)
  2. **Ingresos por plaza** (Bar Chart)
  3. **Transacciones recientes** (Tabla)
  4. **Tendencia de ventas** (Line Chart)
- Estadísticas en tiempo real
- Filtros y visualización de datos

### 👤 Panel de Cliente (Mi Cuenta)
- Ver locales comprados/apartados
- Información detallada de cada local
- Descargar PDF de transacciones
- Estado de apartados (días restantes)

### 📄 Generación de PDFs
- PDF automático al completar compra/apartado
- Incluye:
  - Datos del cliente
  - Información del local
  - Detalles de la transacción
  - Políticas de compra/apartado
  - Fecha y hora
- Descarga desde "Mi Cuenta"

### 🏪 Sistema de Apartado
- 4 opciones de duración:
  - 15 días → 15% del precio
  - 30 días → 25% del precio
  - 60 días → 35% del precio
  - 90 días → 50% del precio
- Fecha de vencimiento automática
- Precio diferenciado vs compra directa

---

## ⏳ Tiempo de Espera

Después de ejecutar la migración SQL, espera **30-60 segundos** para que los contenedores de Azure se inicien completamente.

---

## 🔍 Verificación

### Verificar que el backend funciona:

```powershell
curl http://plazas-backend-2024.eastus.azurecontainer.io:5000/api/health
```

Deberías ver: `{"status":"OK","message":"API funcionando correctamente"}`

### Verificar que la migración se ejecutó:

En pgAdmin, ejecuta:

```sql
SELECT * FROM usuarios WHERE email = 'admin@plazas.com';
```

Deberías ver el usuario admin creado.

---

## 📝 Notas Importantes

1. **PayPal Sandbox**: El sistema usa credenciales de PayPal Sandbox para pruebas
2. **Contraseñas**: Las contraseñas se hashean con bcrypt (10 rounds)
3. **Tokens JWT**: Expiran en 7 días, se guardan en localStorage
4. **Optimización móvil**: El frontend está optimizado para dispositivos móviles
5. **Base de datos**: PostgreSQL en Azure Container Instance

---

## 🚀 Próximos Pasos (Opcionales)

- Configurar dominio personalizado
- Agregar envío de emails con Nodemailer
- Implementar recuperación de contraseña
- Agregar más gráficas al dashboard
- Exportar reportes en Excel
- Notificaciones push para apartados próximos a vencer

---

## 📞 Soporte

Si encuentras algún problema:

1. Verifica que los contenedores estén corriendo en Azure Portal
2. Revisa los logs de los contenedores
3. Confirma que la migración SQL se ejecutó correctamente
4. Verifica la conectividad a la base de datos

---

**¡Listo para usar! 🎉**
