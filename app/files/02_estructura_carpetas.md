# 📁 Estructura de Carpetas — Gestioo (Next.js + Supabase)

```
garage
├── .env.local                        # Variables de entorno (nunca en git)
├── .env.example                      # Plantilla pública de variables
├── next.config.js
├── tailwind.config.js
├── tsconfig.json
├── package.json
│
├── public/
│   └── logo.svg
│
└── src/
    │
    ├── app/                          # App Router de Next.js
    │   │
    │   ├── (auth)/                   # Rutas públicas (sin autenticación)
    │   │   ├── login/
    │   │   │   └── page.tsx
    │   │   └── registro/
    │   │       └── page.tsx
    │   │
    │   ├── (dashboard)/              # Rutas protegidas del taller
    │   │   ├── layout.tsx            # Layout con sidebar + header
    │   │   │
    │   │   ├── page.tsx              # Dashboard / KPIs
    │   │   │
    │   │   ├── ordenes/
    │   │   │   ├── page.tsx          # Lista de órdenes (Kanban + tabla)
    │   │   │   ├── nueva/
    │   │   │   │   └── page.tsx      # Crear orden
    │   │   │   └── [id]/
    │   │   │       ├── page.tsx      # Ver detalle de orden
    │   │   │       └── editar/
    │   │   │           └── page.tsx
    │   │   │
    │   │   ├── clientes/
    │   │   │   ├── page.tsx
    │   │   │   ├── nuevo/
    │   │   │   │   └── page.tsx
    │   │   │   └── [id]/
    │   │   │       └── page.tsx
    │   │   │
    │   │   ├── vehiculos/
    │   │   │   ├── page.tsx
    │   │   │   ├── nuevo/
    │   │   │   │   └── page.tsx
    │   │   │   └── [id]/
    │   │   │       └── page.tsx
    │   │   │
    │   │   ├── inventario/           # Fase 2
    │   │   │   └── page.tsx
    │   │   │
    │   │   ├── reportes/             # Fase 2
    │   │   │   └── page.tsx
    │   │   │
    │   │   └── configuracion/
    │   │       └── page.tsx
    │   │
    │   └── api/                      # API Routes de Next.js
    │       ├── auth/
    │       │   └── callback/
    │       │       └── route.ts      # Callback de Supabase Auth
    │       └── ordenes/
    │           └── [id]/
    │               └── pdf/
    │                   └── route.ts  # Generar PDF de orden
    │
    ├── components/
    │   │
    │   ├── ui/                       # Componentes base (shadcn/ui)
    │   │   ├── button.tsx
    │   │   ├── input.tsx
    │   │   ├── modal.tsx
    │   │   ├── badge.tsx
    │   │   ├── card.tsx
    │   │   └── table.tsx
    │   │
    │   ├── layout/                   # Estructura de la app
    │   │   ├── Sidebar.tsx
    │   │   ├── Header.tsx
    │   │   └── PageContainer.tsx
    │   │
    │   ├── ordenes/                  # Componentes específicos de órdenes
    │   │   ├── OrdenCard.tsx
    │   │   ├── OrdenKanban.tsx
    │   │   ├── OrdenEstadoBadge.tsx
    │   │   ├── FormOrden.tsx
    │   │   ├── TablaServicios.tsx
    │   │   └── TablaRepuestos.tsx
    │   │
    │   ├── clientes/
    │   │   ├── ClienteCard.tsx
    │   │   └── FormCliente.tsx
    │   │
    │   ├── vehiculos/
    │   │   ├── VehiculoCard.tsx
    │   │   └── FormVehiculo.tsx
    │   │
    │   └── dashboard/
    │       ├── KPICard.tsx
    │       └── OrdenesRecientes.tsx
    │
    ├── lib/
    │   ├── supabase/
    │   │   ├── client.ts             # Cliente Supabase para el browser
    │   │   ├── server.ts             # Cliente Supabase para Server Components
    │   │   └── middleware.ts         # Refresh de sesión en middleware
    │   │
    │   ├── utils.ts                  # Helpers generales (formatear fechas, etc.)
    │   ├── constants.ts              # Constantes (estados, tipos, etc.)
    │   └── pdf/
    │       └── generarOrdenPDF.ts    # Lógica de generación de PDF
    │
    ├── hooks/                        # React hooks personalizados
    │   ├── useOrdenes.ts
    │   ├── useClientes.ts
    │   ├── useVehiculos.ts
    │   └── useTaller.ts              # Contexto del taller actual
    │
    ├── types/                        # TypeScript types
    │   ├── database.ts               # Tipos generados por Supabase CLI
    │   └── index.ts                  # Tipos propios del proyecto
    │
    └── middleware.ts                 # Protección de rutas autenticadas
```

---

## 🧭 Convenciones importantes

### Rutas protegidas
Todo lo que esté dentro de `(dashboard)/` requiere sesión activa.
El `middleware.ts` redirige a `/login` si no hay sesión.

### Supabase: dos clientes distintos
- `lib/supabase/client.ts` → Para componentes del browser (useState, eventos)
- `lib/supabase/server.ts` → Para Server Components y API routes (más seguro)

### Tipado de la base de datos
Después de crear las tablas en Supabase, genera los tipos automáticamente:
```bash
npx supabase gen types typescript --project-id TU_PROJECT_ID > src/types/database.ts
```
Esto te da autocompletado perfecto en todo el proyecto.

### Nomenclatura de archivos
- Componentes: `PascalCase.tsx`
- Hooks, utils, lib: `camelCase.ts`
- Páginas (App Router): siempre `page.tsx`
