# 🔧 EJECUTAR SQL EN ORDEN CORRECTO

## ❌ Problema

El error `relation "transacciones" does not exist` significa que la base de datos está vacía.

---

## ✅ Solución: Ejecutar 3 archivos SQL en orden

Debes ejecutar estos archivos SQL **en este orden exacto**:

---

### **1️⃣ PRIMERO: schema-postgres.sql**

**¿Qué hace?**
- Crea las tablas base: `plazas`, `locales`, `clientes`, `transacciones`
- Crea los índices

**Cómo ejecutar:**
1. En pgAdmin Query Tool (donde ya estás)
2. Click en 📁 (Open File)
3. Navega a: `C:\Users\marco\Downloads\plaza-comercial\database\schema-postgres.sql`
4. Abre el archivo
5. Click en ▶️ (Execute) o presiona F5
6. Verifica: "Query returned successfully" ✅

---

### **2️⃣ SEGUNDO: seed-postgres.sql**

**¿Qué hace?**
- Inserta las 5 plazas comerciales
- Inserta los 106 locales con sus coordenadas
- Datos de ejemplo

**Cómo ejecutar:**
1. En pgAdmin Query Tool
2. Click en 📁 (Open File)
3. Navega a: `C:\Users\marco\Downloads\plaza-comercial\database\seed-postgres.sql`
4. Abre el archivo
5. Click en ▶️ (Execute) o presiona F5
6. Verifica: "Query returned successfully" ✅

---

### **3️⃣ TERCERO: migracion-auth.sql**

**¿Qué hace?**
- Crea la tabla `usuarios`
- Inserta el usuario admin (admin@plazas.com / Admin123!)
- Agrega columnas de apartado a `transacciones`
- Agrega columna `precio_apartado` a `locales`

**Cómo ejecutar:**
1. En pgAdmin Query Tool
2. Click en 📁 (Open File)
3. Navega a: `C:\Users\marco\Downloads\plaza-comercial\database\migracion-auth.sql`
4. Abre el archivo
5. Click en ▶️ (Execute) o presiona F5
6. Verifica: "Query returned successfully" ✅

---

## 📋 Resumen de Pasos

```
1. schema-postgres.sql    → Crea tablas base
2. seed-postgres.sql      → Inserta datos de plazas y locales
3. migracion-auth.sql     → Agrega autenticación
```

**Tiempo total: 3 minutos**

---

## ✅ Verificación

Después de ejecutar los 3 archivos, ejecuta esto en Query Tool:

```sql
-- Verificar que todas las tablas existen
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;
```

Deberías ver:
- ✅ clientes
- ✅ locales
- ✅ plazas
- ✅ transacciones
- ✅ usuarios

---

## 🧪 Probar el Login

1. Vuelve al navegador
2. Recarga la página del login (F5)
3. Ingresa:
   ```
   Email:    admin@plazas.com
   Password: Admin123!
   ```
4. Click en "Entrar"

**¡Deberías ver el Dashboard!** 🎉

---

## 📊 Datos que tendrás después

- **5 plazas**: Plaza Satélite, Plaza Naucalpan, Plaza Tlalnepantla, Plaza Ecatepec, Plaza Cuautitlán
- **106 locales** distribuidos en las 5 plazas
- **1 usuario admin**: admin@plazas.com
- **Sistema completo** listo para usar

---

## ⚠️ Notas Importantes

- **Orden**: Es crucial ejecutar los archivos en el orden indicado
- **Errores**: Si un archivo da error, no continúes con el siguiente
- **Limpieza**: Si necesitas empezar de cero, ejecuta:
  ```sql
  DROP TABLE IF EXISTS transacciones CASCADE;
  DROP TABLE IF EXISTS usuarios CASCADE;
  DROP TABLE IF EXISTS clientes CASCADE;
  DROP TABLE IF EXISTS locales CASCADE;
  DROP TABLE IF EXISTS plazas CASCADE;
  ```
  Y luego vuelve a ejecutar los 3 archivos en orden.

---

## 🎯 Después de completar

El sistema estará 100% funcional con:
- ✅ Login y registro
- ✅ Dashboard de admin con gráficas
- ✅ 5 plazas comerciales
- ✅ 106 locales para comprar/apartar
- ✅ Sistema de apartado
- ✅ Generación de PDFs
- ✅ Panel de cliente

---

**¡Ejecuta los 3 archivos SQL y el sistema estará listo!** 🚀
