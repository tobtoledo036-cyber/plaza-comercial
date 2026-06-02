# 🔧 SOLUCIÓN: Error "relation usuarios does not exist"

## ❌ Problema

El login muestra el error: `relation "usuarios" does not exist`

**Causa**: La tabla `usuarios` no existe en la base de datos porque la migración SQL no se ha ejecutado.

---

## ✅ Solución (1 minuto)

### **El SQL ya está copiado en tu portapapeles** 📋

Solo sigue estos pasos:

---

### **Paso 1: Abre pgAdmin 4**

Busca pgAdmin 4 en tu menú de inicio y ábrelo.

---

### **Paso 2: Conéctate a tu servidor de Azure**

En el panel izquierdo de pgAdmin:

1. Expande: **Servers**
2. Busca: **Plazas Azure** (o el nombre que le hayas dado)
3. Si no existe, créalo:
   - Click derecho en "Servers" → "Register" → "Server"
   - **General tab**:
     - Name: `Plazas Azure`
   - **Connection tab**:
     - Host: `plazas-postgres-2024.eastus.azurecontainer.io`
     - Port: `5432`
     - Maintenance database: `plazas_db`
     - Username: `plazasadmin`
     - Password: `TuPassword123!`
     - ✅ Save password
   - Click "Save"

---

### **Paso 3: Abre Query Tool**

1. Expande: **Servers > Plazas Azure > Databases**
2. Click derecho en **plazas_db**
3. Selecciona: **Query Tool**

Se abrirá una nueva ventana con un editor SQL.

---

### **Paso 4: Pega el SQL**

En la ventana del Query Tool:

1. Click en el área de texto (editor SQL)
2. Presiona **Ctrl + V** para pegar
3. Verás todo el código SQL aparecer

---

### **Paso 5: Ejecuta**

1. Click en el botón **▶️ Execute/Refresh** (o presiona **F5**)
2. Espera unos segundos
3. En la parte inferior verás: **"Query returned successfully"** ✅

---

### **Paso 6: Verifica**

En la parte inferior de pgAdmin, deberías ver algo como:

```
tabla          | count
---------------+-------
usuarios       | 1
transacciones  | X
```

Esto confirma que:
- ✅ Tabla `usuarios` creada
- ✅ Usuario admin insertado
- ✅ Columnas de apartado agregadas

---

### **Paso 7: Prueba el login**

1. Vuelve a tu navegador
2. Recarga la página del login (F5)
3. Ingresa:
   ```
   Email:    admin@plazas.com
   Password: Admin123!
   ```
4. Click en **"Entrar"**

**¡Deberías ver el Dashboard de administrador!** 🎉

---

## 📊 ¿Qué hace la migración?

La migración SQL ejecuta estos cambios en la base de datos:

1. **Crea tabla `usuarios`**:
   - Campos: id, nombre, email, password_hash, rol, telefono, activo, created_at
   - Roles: 'admin' o 'cliente'

2. **Inserta usuario admin**:
   - Email: admin@plazas.com
   - Password: Admin123! (hasheada con bcrypt)
   - Rol: admin

3. **Agrega columnas a `transacciones`**:
   - duracion_apartado_dias
   - porcentaje_apartado
   - fecha_vencimiento_apartado
   - usuario_id (relación con usuarios)

4. **Agrega columna a `locales`**:
   - precio_apartado (30% del precio de compra)

5. **Crea índices**:
   - idx_usuarios_email (para búsquedas rápidas)
   - idx_trans_usuario (para consultas de transacciones por usuario)

---

## 🔍 Verificación Adicional

Si quieres verificar que el usuario admin se creó correctamente, ejecuta en Query Tool:

```sql
SELECT * FROM usuarios WHERE email = 'admin@plazas.com';
```

Deberías ver:

| id | nombre | email | rol | activo |
|----|--------|-------|-----|--------|
| 1 | Administrador | admin@plazas.com | admin | true |

---

## ⚠️ Si aún tienes problemas

### Error: "Could not connect to server"

**Solución**: Verifica que el contenedor de PostgreSQL esté corriendo:

```powershell
az container show --resource-group plazas-rg-eastus --name plazas-postgres --query "instanceView.state"
```

Debería mostrar: `"Running"`

Si no está corriendo:

```powershell
az container start --resource-group plazas-rg-eastus --name plazas-postgres
```

---

### Error: "Password authentication failed"

**Solución**: Verifica que estás usando la contraseña correcta: `TuPassword123!`

---

### Error: "Database plazas_db does not exist"

**Solución**: La base de datos no existe. Necesitas crearla primero:

```sql
CREATE DATABASE plazas_db;
```

---

## 📞 Resumen

1. ✅ SQL copiado al portapapeles
2. ⏱️ Abre pgAdmin (30 segundos)
3. ⏱️ Pega y ejecuta SQL (30 segundos)
4. ✅ Recarga login y prueba

**Tiempo total: 1 minuto**

---

## 🎯 Después de la migración

Una vez que el login funcione, podrás:

- ✅ Ver el Dashboard de administrador con 4 gráficas
- ✅ Registrar nuevos clientes
- ✅ Comprar y apartar locales
- ✅ Descargar PDFs de transacciones
- ✅ Ver "Mi Cuenta" con locales comprados/apartados

---

**¡Listo! El sistema estará 100% funcional después de ejecutar la migración.** 🚀
