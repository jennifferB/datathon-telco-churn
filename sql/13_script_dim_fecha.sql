-- Ejecutar en la base telco_g2, cada sentencia por separado.
-- Calendario técnico: no representa fechas de abandono del CSV.
-- 2000-01-01 a 2099-12-31 inclusive: 36525 fechas.
CREATE TABLE IF NOT EXISTS dim_fecha_telco_g2 (
    fecha DATE NOT NULL,
    anio INT NOT NULL,
    trimestre TINYINT NOT NULL,
    mes TINYINT NOT NULL,
    dia TINYINT NOT NULL,
    dia_semana TINYINT NOT NULL,
    es_fin_semana TINYINT NOT NULL,

    PRIMARY KEY (fecha),
    SHARD KEY (fecha)
);


INSERT IGNORE INTO dim_fecha_telco_g2 (
    fecha,
    anio,
    trimestre,
    mes,
    dia,
    dia_semana,
    es_fin_semana
)
SELECT
    d.fecha,
    YEAR(d.fecha),
    QUARTER(d.fecha),
    MONTH(d.fecha),
    DAYOFMONTH(d.fecha),
    DAYOFWEEK(d.fecha),
    CASE
        WHEN DAYOFWEEK(d.fecha) IN (1, 7) THEN 1
        ELSE 0
    END
FROM (
    SELECT
        DATE_ADD(
            '2000-01-01',
            INTERVAL (
                a.n + b.n * 10 + c.n * 100 + e.n * 1000 + f.n * 10000
            ) DAY
        ) AS fecha
    FROM
        (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
    CROSS JOIN
        (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    CROSS JOIN
        (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c
    CROSS JOIN
        (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) e
    CROSS JOIN
        (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) f
) d
WHERE d.fecha <= '2099-12-31';
