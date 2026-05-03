-- ============================================================================
-- DATA WAREHOUSE 
-- Esquema: dwAnalytics
-- Tabla: ReporteRentabilidadGlobal
-- ============================================================================
CREATE DATABASE datawarehouse;
\c datawarehouse

CREATE SCHEMA IF NOT EXISTS dwAnalytics;

DROP TABLE IF EXISTS dwAnalytics.ReporteRentabilidadGlobal;

CREATE TABLE dwAnalytics.ReporteRentabilidadGlobal (
    "idVenta" SERIAL PRIMARY KEY,
    "fechaVenta" DATE NOT NULL,
    
    "skuProducto" VARCHAR(50) NOT NULL,
    "nombreProducto" VARCHAR(50),
    "tipoProducto" VARCHAR(50),
    "esMarcaIa" BOOLEAN DEFAULT FALSE,
    "marcaBlanca" VARCHAR(100),
    

    "paisVenta" VARCHAR(50),
    "ciudadVenta" VARCHAR(50),
    "tiendaOrigen" VARCHAR(100),
    

    "cantidad_vendida" DECIMAL(12,2) NOT NULL,
    
    "monedaOriginal" CHAR(3),
    "precioUnitarioLocal" DECIMAL(14,2),
    "precioUnitario" DECIMAL(14,2),
    "ingresoTotal" DECIMAL(14,2),
    

    "costoTotalUnitario" DECIMAL(14,4),
    

    "costoTotalVenta" DECIMAL(14,4), 
    "margenBrutoUnitario" DECIMAL(14,2),
    "margenPorcentaje" DECIMAL(5,2),
    
    -- Auditoría
    "fechaProceso" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE INDEX idx_reporte_fecha ON dwAnalytics.ReporteRentabilidadGlobal("fechaVenta");
CREATE INDEX idx_reporte_sku ON dwAnalytics.ReporteRentabilidadGlobal("skuProducto");
CREATE INDEX idx_reporte_pais ON dwAnalytics.ReporteRentabilidadGlobal("paisVenta");
CREATE INDEX idx_reporte_categoria ON dwAnalytics.ReporteRentabilidadGlobal("tipoProducto");
CREATE INDEX idx_reporte_tienda ON dwAnalytics.ReporteRentabilidadGlobal("tiendaOrigen");
