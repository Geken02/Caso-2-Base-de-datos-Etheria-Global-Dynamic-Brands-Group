-- ============================================================================
-- DATA WAREHOUSE SIMPLIFICADO (PostgreSQL)
-- Esquema: dw_analytics
-- Tabla: ReporteRentabilidadGlobal
-- ============================================================================

-- 1. Crear el Esquema (Si no existe)
CREATE SCHEMA IF NOT EXISTS dw_analytics;

DROP TABLE IF EXISTS dw_analytics.ReporteRentabilidadGlobal;

CREATE TABLE dw_analytics.ReporteRentabilidadGlobal (
    id_venta SERIAL PRIMARY KEY,
    fecha_venta DATE NOT NULL,
    
    -- Dimensiones Denormalizadas (Texto directo)
    producto_sku VARCHAR(50) NOT NULL,
    nombre_producto VARCHAR(150),
    categoria VARCHAR(50),
    es_marca_ia BOOLEAN DEFAULT FALSE,
    marca_blanca VARCHAR(100),
    
    -- Ubicación y Tienda
    pais_venta VARCHAR(50),
    ciudad_venta VARCHAR(50),
    tienda_origen VARCHAR(100),
    
    -- Métricas de Cantidad
    cantidad_vendida DECIMAL(12,2) NOT NULL,
    
    -- Ingresos (Convertidos a USD por el ETL Python)
    moneda_original CHAR(3),
    precio_unitario_local DECIMAL(14,2),
    precio_unitario_usd DECIMAL(14,2),
    ingreso_total_usd DECIMAL(14,2),
    
    -- Costos Totales Unitarios (Landed Cost: Compra + Fletes + Seguros rateados)
    -- No desglosamos columnas individuales para mantener la simplicidad, 
    -- el cálculo de rateo se hace en Python antes de insertar.
    costo_total_unitario_usd DECIMAL(14,4),
    
    -- Totales Calculados
    costo_total_venta_usd DECIMAL(14,4), -- costo_unitario * cantidad
    margen_bruto_unitario_usd DECIMAL(14,2),
    margen_porcentaje DECIMAL(5,2),
    
    -- Auditoría
    fecha_proceso TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Índices para Rendimiento de Consultas
CREATE INDEX idx_reporte_fecha ON dw_analytics.ReporteRentabilidadGlobal(fecha_venta);
CREATE INDEX idx_reporte_sku ON dw_analytics.ReporteRentabilidadGlobal(producto_sku);
CREATE INDEX idx_reporte_pais ON dw_analytics.ReporteRentabilidadGlobal(pais_venta);
CREATE INDEX idx_reporte_categoria ON dw_analytics.ReporteRentabilidadGlobal(categoria);
CREATE INDEX idx_reporte_tienda ON dw_analytics.ReporteRentabilidadGlobal(tienda_origen);
