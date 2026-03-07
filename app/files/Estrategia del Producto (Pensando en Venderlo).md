1️⃣ Estrategia del Producto (Pensando en Venderlo)
Antes de escribir una sola línea de código, debes definir:
🎯 Nicho objetivo
En Panamá hay:
•	Talleres pequeños (1–3 mecánicos)
•	Talleres medianos (5–15 empleados)
•	Talleres grandes multimarca
•	Talleres especializados (transmisión, electricidad, aire acondicionado)
👉 Recomendación: Comenzar con talleres pequeños y medianos. Son el 80% del mercado y no tienen software profesional.
________________________________________
2️⃣ ¿Qué es lo MÁS importante construir primero?
NO empieces por inventario.
NO empieces por reportes.
NO empieces por facturación electrónica.
Empieza por:
🔥 MÓDULO CORE: ÓRDENES DE TRABAJO
Si no dominas esto, no tienes producto.
El sistema debe permitir:
•	Crear cliente
•	Crear vehículo
•	Crear orden de trabajo
•	Agregar diagnóstico
•	Agregar servicios
•	Agregar repuestos
•	Calcular totales
•	Cambiar estado (Pendiente, En Proceso, Terminado, Entregado)
•	Historial del vehículo
Eso es el corazón del negocio.
________________________________________
3️⃣ Arquitectura Recomendada (Pensando en Escalar)
Si lo quieres vender en Panamá de forma seria:
Backend:
•	Node.js (NestJS) o Laravel
•	API REST
•	Multi-tenant (MUY IMPORTANTE)
Frontend:
•	React o Next.js
•	Panel administrativo moderno
Base de datos:
•	PostgreSQL
Infraestructura:
•	VPS o cloud (DigitalOcean / AWS)
________________________________________
4️⃣ Diseño de Base de Datos (Versión Profesional)
Aquí está la estructura mínima correcta:
🏢 Tabla: talleres
•	id
•	nombre
•	ruc
•	direccion
•	telefono
•	plan
•	estado
________________________________________
👤 Tabla: usuarios
•	id
•	taller_id
•	nombre
•	email
•	password
•	rol (admin, mecanico, recepcionista)
________________________________________
👥 Tabla: clientes
•	id
•	taller_id
•	nombre
•	cedula
•	telefono
•	email
•	direccion
________________________________________
🚗 Tabla: vehiculos
•	id
•	taller_id
•	cliente_id
•	marca
•	modelo
•	año
•	placa
•	vin
•	kilometraje
________________________________________
📋 Tabla: ordenes_trabajo
•	id
•	taller_id
•	cliente_id
•	vehiculo_id
•	numero_orden
•	fecha_ingreso
•	estado
•	diagnostico
•	total
•	observaciones
________________________________________
🔧 Tabla: orden_servicios
•	id
•	orden_id
•	descripcion
•	precio
________________________________________
🧩 Tabla: orden_repuestos
•	id
•	orden_id
•	nombre
•	cantidad
•	precio_unitario
________________________________________
💡 Nota profesional:
Siempre incluir taller_id en todas las tablas para que sea multi-empresa.
________________________________________
5️⃣ Paso a Paso para Trabajar con Claude
Ahora viene lo que quieres: los prompts estratégicos para que Claude lo construya bien.
No le pidas todo de golpe.
Se trabaja por módulos.
________________________________________
🔵 PASO 1 — Arquitectura Base
Prompt para Claude:
Quiero construir un software SaaS para talleres mecánicos en Panamá.

Necesito que me diseñes la arquitectura completa del sistema bajo estos requisitos:

- Multi-tenant (cada taller debe tener sus propios datos aislados)
- Backend en Node.js con NestJS
- Base de datos PostgreSQL
- Autenticación con JWT
- Roles: admin, mecanico, recepcionista
- API REST bien estructurada
- Preparado para escalar a miles de talleres

Quiero:

1) Estructura de carpetas profesional
2) Diseño modular
3) Mejores prácticas
4) Explicación técnica de cada decisión
________________________________________
🔵 PASO 2 — Base de Datos Profesional
Prompt para Claude:
Diseña el esquema completo en PostgreSQL para un software SaaS de gestión de talleres mecánicos en Panamá.

Debe incluir:

- Multi-tenant
- Talleres
- Usuarios con roles
- Clientes
- Vehículos
- Órdenes de trabajo
- Servicios dentro de la orden
- Repuestos dentro de la orden
- Estados de orden
- Historial del vehículo

Quiero:

- Modelo entidad-relación explicado
- Scripts SQL listos para ejecutar
- Índices optimizados
- Relaciones correctas con foreign keys
- Buenas prácticas de rendimiento
________________________________________
🔵 PASO 3 — Backend: Módulo de Órdenes
Desarrolla el módulo completo de órdenes de trabajo usando NestJS.

Debe incluir:

- Crear orden
- Editar orden
- Cambiar estado
- Agregar servicios
- Agregar repuestos
- Calcular total automáticamente
- Validaciones robustas
- DTOs
- Controladores
- Servicios
- Repositorios
- Tests básicos

Quiero código limpio y profesional.
________________________________________
🔵 PASO 4 — Sistema Multi-Tenant Correcto
Explícame la mejor estrategia para implementar multi-tenancy en PostgreSQL para un SaaS de talleres mecánicos.

Compara:

1) Base de datos por cliente
2) Schema por cliente
3) Columna tenant_id compartida

Recomiéndame la mejor opción considerando que quiero vender el sistema a talleres pequeños y medianos en Panamá.
________________________________________
🔵 PASO 5 — Pensar Comercialmente (Muy Importante)
Luego debes pedirle:
Ayúdame a convertir este software en un producto comercial para talleres en Panamá.

Necesito:

- Modelo de precios recomendado
- Plan básico, profesional y premium
- Estrategia de adquisición de clientes
- Qué funciones dejar para planes superiores
- Cómo diferenciarme de competencia local
- Estrategia para venderlo físicamente visitando talleres
________________________________________
6️⃣ Cosas CLAVE si quieres vender en Panamá
Debes considerar:
🇵🇦 Panamá tiene:
•	Facturación electrónica (DGI)
•	RUC
•	Talleres muy informales
•	Mucho uso de WhatsApp
•	Poco conocimiento tecnológico
Entonces tu sistema debe tener:
•	Enviar orden por WhatsApp
•	PDF profesional con logo
•	Control de cuentas por cobrar
•	Control de caja
•	Reporte simple de ganancias
________________________________________
7️⃣ Error que NO debes cometer
❌ No empieces programando sin definir modelo de negocio.
❌ No hagas el sistema demasiado complejo al inicio.
❌ No ignores el multi-tenant.
❌ No desarrolles sin pensar en cómo venderlo.
________________________________________
🚀 Estrategia Correcta de Desarrollo
Fase 1:
Órdenes + Clientes + Vehículos
Fase 2:
Inventario + Caja + Reportes básicos
Fase 3:
Facturación electrónica Panamá
Fase 4:
App móvil o versión para mecánicos

