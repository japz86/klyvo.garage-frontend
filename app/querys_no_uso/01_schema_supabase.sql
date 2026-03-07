-- ============================================================
-- GESTIOO - Schema completo para Supabase (PostgreSQL)
-- Versión: 1.0 | Fase 1 - MVP
-- Multi-tenant con aislamiento por taller_id
-- ============================================================

-- ============================================================
-- EXTENSIONES
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- ============================================================
-- 1. TALLERES
-- Cada taller es un tenant independiente
-- ============================================================
CREATE TABLE talleres (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre      TEXT NOT NULL,
  ruc         TEXT,
  direccion   TEXT,
  telefono    TEXT,
  email       TEXT,
  logo_url    TEXT,
  plan        TEXT NOT NULL DEFAULT 'basico' CHECK (plan IN ('basico', 'profesional', 'premium')),
  estado      TEXT NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo', 'suspendido', 'cancelado')),
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);


-- ============================================================
-- 2. SUSCRIPCIONES
-- Control de plan activo por taller
-- ============================================================
CREATE TABLE suscripciones (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taller_id        UUID NOT NULL REFERENCES talleres(id) ON DELETE CASCADE,
  plan             TEXT NOT NULL DEFAULT 'basico',
  estado           TEXT NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo', 'vencido', 'cancelado')),
  fecha_inicio     DATE NOT NULL DEFAULT CURRENT_DATE,
  fecha_fin        DATE,
  limite_usuarios  INT NOT NULL DEFAULT 2,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_suscripciones_taller ON suscripciones(taller_id);


-- ============================================================
-- 3. USUARIOS
-- Vinculados a Supabase Auth mediante auth_id
-- ============================================================
CREATE TABLE usuarios (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taller_id   UUID NOT NULL REFERENCES talleres(id) ON DELETE CASCADE,
  auth_id     UUID UNIQUE, -- Referencia a auth.users de Supabase
  nombre      TEXT NOT NULL,
  email       TEXT NOT NULL,
  telefono    TEXT,
  rol         TEXT NOT NULL DEFAULT 'mecanico' CHECK (rol IN ('admin', 'mecanico', 'recepcionista')),
  activo      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_usuarios_taller    ON usuarios(taller_id);
CREATE INDEX idx_usuarios_auth      ON usuarios(auth_id);
CREATE UNIQUE INDEX idx_usuarios_email_taller ON usuarios(taller_id, email);


-- ============================================================
-- 4. CLIENTES
-- Personas que llevan vehículos al taller
-- ============================================================
CREATE TABLE clientes (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taller_id   UUID NOT NULL REFERENCES talleres(id) ON DELETE CASCADE,
  nombre      TEXT NOT NULL,
  cedula      TEXT,
  ruc         TEXT,
  telefono    TEXT,
  email       TEXT,
  direccion   TEXT,
  notas       TEXT,
  activo      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_clientes_taller  ON clientes(taller_id);
CREATE INDEX idx_clientes_cedula  ON clientes(taller_id, cedula);
CREATE INDEX idx_clientes_nombre  ON clientes(taller_id, nombre);


-- ============================================================
-- 5. ACTIVOS (Vehículos)
-- Entidad permanente - el vehículo existe independiente del dueño
-- ============================================================
CREATE TABLE activos (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taller_id     UUID NOT NULL REFERENCES talleres(id) ON DELETE CASCADE,
  marca         TEXT NOT NULL,
  modelo        TEXT NOT NULL,
  anio          INT,
  placa         TEXT,
  vin           TEXT,
  color         TEXT,
  tipo          TEXT DEFAULT 'automovil' CHECK (tipo IN ('automovil', 'pickup', 'moto', 'camion', 'bus', 'otro')),
  kilometraje   INT DEFAULT 0,
  notas         TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_activos_taller ON activos(taller_id);
CREATE UNIQUE INDEX idx_activos_placa ON activos(taller_id, placa) WHERE placa IS NOT NULL;
CREATE UNIQUE INDEX idx_activos_vin   ON activos(taller_id, vin)   WHERE vin IS NOT NULL;


-- ============================================================
-- 6. ACTIVO_PROPIETARIOS
-- Historial de propietarios por vehículo
-- El historial nunca se pierde aunque cambie de dueño
-- ============================================================
CREATE TABLE activo_propietarios (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taller_id     UUID NOT NULL REFERENCES talleres(id) ON DELETE CASCADE,
  activo_id     UUID NOT NULL REFERENCES activos(id) ON DELETE CASCADE,
  cliente_id    UUID NOT NULL REFERENCES clientes(id) ON DELETE RESTRICT,
  es_actual     BOOLEAN NOT NULL DEFAULT TRUE,
  fecha_inicio  DATE DEFAULT CURRENT_DATE,
  fecha_fin     DATE,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_propietarios_activo  ON activo_propietarios(activo_id);
CREATE INDEX idx_propietarios_cliente ON activo_propietarios(cliente_id);
CREATE INDEX idx_propietarios_taller  ON activo_propietarios(taller_id);


-- ============================================================
-- 7. ORDENES DE TRABAJO
-- El corazón del sistema
-- ============================================================
CREATE TABLE ordenes_trabajo (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taller_id       UUID NOT NULL REFERENCES talleres(id) ON DELETE CASCADE,
  cliente_id      UUID NOT NULL REFERENCES clientes(id) ON DELETE RESTRICT,
  activo_id       UUID NOT NULL REFERENCES activos(id) ON DELETE RESTRICT,
  numero_orden    SERIAL, -- Auto-incremental por taller (ver función abajo)
  estado          TEXT NOT NULL DEFAULT 'pendiente' CHECK (
                    estado IN ('pendiente', 'en_proceso', 'terminado', 'entregado', 'cancelado')
                  ),
  fecha_ingreso   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  fecha_estimada  DATE,
  fecha_entrega   TIMESTAMPTZ,
  kilometraje     INT,
  diagnostico     TEXT,
  observaciones   TEXT,
  notas_internas  TEXT,
  subtotal        NUMERIC(10,2) NOT NULL DEFAULT 0,
  descuento       NUMERIC(10,2) NOT NULL DEFAULT 0,
  itbms           NUMERIC(10,2) NOT NULL DEFAULT 0,   -- 7% impuesto Panamá
  total           NUMERIC(10,2) NOT NULL DEFAULT 0,
  asignado_a      UUID REFERENCES usuarios(id),       -- Mecánico responsable
  created_by      UUID REFERENCES usuarios(id),
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ordenes_taller       ON ordenes_trabajo(taller_id);
CREATE INDEX idx_ordenes_cliente      ON ordenes_trabajo(taller_id, cliente_id);
CREATE INDEX idx_ordenes_activo       ON ordenes_trabajo(taller_id, activo_id);
CREATE INDEX idx_ordenes_estado       ON ordenes_trabajo(taller_id, estado);
CREATE INDEX idx_ordenes_fecha        ON ordenes_trabajo(taller_id, fecha_ingreso DESC);


-- ============================================================
-- 8. ORDEN_SERVICIOS
-- Mano de obra incluida en la orden
-- ============================================================
CREATE TABLE orden_servicios (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taller_id    UUID NOT NULL REFERENCES talleres(id) ON DELETE CASCADE,
  orden_id     UUID NOT NULL REFERENCES ordenes_trabajo(id) ON DELETE CASCADE,
  descripcion  TEXT NOT NULL,
  cantidad     NUMERIC(10,2) NOT NULL DEFAULT 1,
  precio       NUMERIC(10,2) NOT NULL DEFAULT 0,
  subtotal     NUMERIC(10,2) GENERATED ALWAYS AS (cantidad * precio) STORED,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_orden_servicios_orden  ON orden_servicios(orden_id);
CREATE INDEX idx_orden_servicios_taller ON orden_servicios(taller_id);


-- ============================================================
-- 9. ORDEN_REPUESTOS
-- Repuestos o piezas usadas en la orden
-- ============================================================
CREATE TABLE orden_repuestos (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taller_id       UUID NOT NULL REFERENCES talleres(id) ON DELETE CASCADE,
  orden_id        UUID NOT NULL REFERENCES ordenes_trabajo(id) ON DELETE CASCADE,
  nombre          TEXT NOT NULL,
  referencia      TEXT,
  cantidad        NUMERIC(10,2) NOT NULL DEFAULT 1,
  precio_unitario NUMERIC(10,2) NOT NULL DEFAULT 0,
  subtotal        NUMERIC(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_orden_repuestos_orden  ON orden_repuestos(orden_id);
CREATE INDEX idx_orden_repuestos_taller ON orden_repuestos(taller_id);


-- ============================================================
-- 10. FOTOS_ORDEN
-- Evidencia fotográfica del trabajo
-- ============================================================
CREATE TABLE fotos_orden (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taller_id   UUID NOT NULL REFERENCES talleres(id) ON DELETE CASCADE,
  orden_id    UUID NOT NULL REFERENCES ordenes_trabajo(id) ON DELETE CASCADE,
  url         TEXT NOT NULL,
  etapa       TEXT DEFAULT 'ingreso' CHECK (etapa IN ('ingreso', 'proceso', 'terminado')),
  descripcion TEXT,
  created_by  UUID REFERENCES usuarios(id),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_fotos_orden ON fotos_orden(orden_id);


-- ============================================================
-- 11. PRODUCTOS (Inventario - Fase 2)
-- Catálogo de repuestos con control de stock
-- ============================================================
CREATE TABLE productos (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taller_id     UUID NOT NULL REFERENCES talleres(id) ON DELETE CASCADE,
  nombre        TEXT NOT NULL,
  referencia    TEXT,
  descripcion   TEXT,
  precio_costo  NUMERIC(10,2) DEFAULT 0,
  precio_venta  NUMERIC(10,2) DEFAULT 0,
  stock_actual  NUMERIC(10,2) NOT NULL DEFAULT 0,
  stock_minimo  NUMERIC(10,2) NOT NULL DEFAULT 0,
  unidad        TEXT DEFAULT 'unidad',
  activo        BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_productos_taller ON productos(taller_id);
CREATE INDEX idx_productos_nombre ON productos(taller_id, nombre);


-- ============================================================
-- 12. MOVIMIENTOS_INVENTARIO (Fase 2)
-- Cada entrada/salida es un movimiento. Stock = SUM()
-- ============================================================
CREATE TABLE movimientos_inventario (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taller_id    UUID NOT NULL REFERENCES talleres(id) ON DELETE CASCADE,
  producto_id  UUID NOT NULL REFERENCES productos(id) ON DELETE RESTRICT,
  orden_id     UUID REFERENCES ordenes_trabajo(id),
  tipo         TEXT NOT NULL CHECK (tipo IN ('entrada', 'salida', 'ajuste')),
  cantidad     NUMERIC(10,2) NOT NULL,
  precio_unit  NUMERIC(10,2),
  motivo       TEXT,
  created_by   UUID REFERENCES usuarios(id),
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_movimientos_taller   ON movimientos_inventario(taller_id);
CREATE INDEX idx_movimientos_producto ON movimientos_inventario(taller_id, producto_id);


-- ============================================================
-- 13. CAJA (Fase 2)
-- Movimientos de dinero separados del inventario
-- ============================================================
CREATE TABLE movimientos_caja (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taller_id   UUID NOT NULL REFERENCES talleres(id) ON DELETE CASCADE,
  tipo        TEXT NOT NULL CHECK (tipo IN ('ingreso', 'egreso')),
  monto       NUMERIC(10,2) NOT NULL,
  concepto    TEXT NOT NULL,
  orden_id    UUID REFERENCES ordenes_trabajo(id),
  fecha       DATE NOT NULL DEFAULT CURRENT_DATE,
  created_by  UUID REFERENCES usuarios(id),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_caja_taller ON movimientos_caja(taller_id);
CREATE INDEX idx_caja_fecha  ON movimientos_caja(taller_id, fecha DESC);


-- ============================================================
-- FUNCIÓN: Actualizar updated_at automáticamente
-- ============================================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a todas las tablas con updated_at
CREATE TRIGGER trg_talleres_updated_at   BEFORE UPDATE ON talleres   FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_usuarios_updated_at   BEFORE UPDATE ON usuarios   FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_clientes_updated_at   BEFORE UPDATE ON clientes   FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_activos_updated_at    BEFORE UPDATE ON activos    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_ordenes_updated_at    BEFORE UPDATE ON ordenes_trabajo FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_productos_updated_at  BEFORE UPDATE ON productos  FOR EACH ROW EXECUTE FUNCTION set_updated_at();


-- ============================================================
-- FUNCIÓN: Recalcular totales de orden automáticamente
-- Se ejecuta cuando se agrega/edita/elimina un servicio o repuesto
-- ============================================================
CREATE OR REPLACE FUNCTION recalcular_total_orden()
RETURNS TRIGGER AS $$
DECLARE
  v_orden_id UUID;
  v_subtotal NUMERIC(10,2);
  v_itbms    NUMERIC(10,2);
BEGIN
  -- Determinar orden_id desde la fila afectada
  IF TG_OP = 'DELETE' THEN
    v_orden_id := OLD.orden_id;
  ELSE
    v_orden_id := NEW.orden_id;
  END IF;

  -- Sumar todos los servicios + repuestos
  SELECT
    COALESCE(SUM(s.subtotal), 0) + COALESCE(SUM(r.subtotal), 0)
  INTO v_subtotal
  FROM ordenes_trabajo o
  LEFT JOIN orden_servicios  s ON s.orden_id = o.id
  LEFT JOIN orden_repuestos  r ON r.orden_id = o.id
  WHERE o.id = v_orden_id
  GROUP BY o.id;

  v_itbms := v_subtotal * 0.07; -- ITBMS 7% Panamá

  UPDATE ordenes_trabajo
  SET
    subtotal = v_subtotal,
    itbms    = v_itbms,
    total    = v_subtotal + v_itbms - descuento
  WHERE id = v_orden_id;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger en servicios
CREATE TRIGGER trg_recalc_por_servicio
AFTER INSERT OR UPDATE OR DELETE ON orden_servicios
FOR EACH ROW EXECUTE FUNCTION recalcular_total_orden();

-- Trigger en repuestos
CREATE TRIGGER trg_recalc_por_repuesto
AFTER INSERT OR UPDATE OR DELETE ON orden_repuestos
FOR EACH ROW EXECUTE FUNCTION recalcular_total_orden();


-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- Cada taller solo ve sus propios datos
-- CRÍTICO para SaaS multi-tenant
-- ============================================================
ALTER TABLE talleres              ENABLE ROW LEVEL SECURITY;
ALTER TABLE suscripciones         ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios              ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes              ENABLE ROW LEVEL SECURITY;
ALTER TABLE activos               ENABLE ROW LEVEL SECURITY;
ALTER TABLE activo_propietarios   ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordenes_trabajo       ENABLE ROW LEVEL SECURITY;
ALTER TABLE orden_servicios       ENABLE ROW LEVEL SECURITY;
ALTER TABLE orden_repuestos       ENABLE ROW LEVEL SECURITY;
ALTER TABLE fotos_orden           ENABLE ROW LEVEL SECURITY;
ALTER TABLE productos             ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos_inventario ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos_caja      ENABLE ROW LEVEL SECURITY;

-- Función helper: obtener taller_id del usuario autenticado
CREATE OR REPLACE FUNCTION get_taller_id()
RETURNS UUID AS $$
  SELECT taller_id FROM usuarios WHERE auth_id = auth.uid() LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Políticas RLS: cada tabla solo devuelve filas del taller del usuario
CREATE POLICY "taller_aislado" ON clientes            USING (taller_id = get_taller_id());
CREATE POLICY "taller_aislado" ON activos             USING (taller_id = get_taller_id());
CREATE POLICY "taller_aislado" ON activo_propietarios USING (taller_id = get_taller_id());
CREATE POLICY "taller_aislado" ON ordenes_trabajo     USING (taller_id = get_taller_id());
CREATE POLICY "taller_aislado" ON orden_servicios     USING (taller_id = get_taller_id());
CREATE POLICY "taller_aislado" ON orden_repuestos     USING (taller_id = get_taller_id());
CREATE POLICY "taller_aislado" ON fotos_orden         USING (taller_id = get_taller_id());
CREATE POLICY "taller_aislado" ON productos           USING (taller_id = get_taller_id());
CREATE POLICY "taller_aislado" ON movimientos_inventario USING (taller_id = get_taller_id());
CREATE POLICY "taller_aislado" ON movimientos_caja    USING (taller_id = get_taller_id());
CREATE POLICY "taller_aislado" ON usuarios            USING (taller_id = get_taller_id());
CREATE POLICY "taller_aislado" ON suscripciones       USING (taller_id = get_taller_id());
