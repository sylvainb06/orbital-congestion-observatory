-- =============================================================== --
-- MART GCAT - Object density by orbital family
-- 1 row = 1 high-level orbital family (LEO / MEO / GEO / HEO / ...)
-- Groups McDowell's fine-grained OpOrbit codes (LLEO/I, GEO/S, ...)
-- into readable families, with count and share (%).
--
-- Grouping follows McDowell's Orbital Categories table:
--   LEO family  : LLEO/* and LEO/* (Low Earth Orbit, below 2000 km)
--   MEO         : MEO (Medium Earth Orbit)
--   GEO family  : GEO/* and GTO (geosynchronous + geo-transfer)
--   HEO family  : HEO, HEO/M (highly elliptical / Molniya)
--   High/Deep   : VHEO, DSO, CLO, EEO, HCO, PCO, SSE (beyond GEO)
--   Low/Sub     : ATM, SO, TA (atmospheric / suborbital / trans-atm)
--
-- NOTE: rows with no orbit code ('-' or NULL) are excluded.
-- =============================================================== --

{{ config(materialized='table') }}

WITH classified AS (
    SELECT
        CASE
            WHEN orbit_class LIKE 'LLEO%'
              OR orbit_class LIKE 'LEO%'          THEN 'LEO (Low Earth Orbit)'
            WHEN orbit_class = 'MEO'              THEN 'MEO (Medium Earth Orbit)'
            WHEN orbit_class LIKE 'GEO%'
              OR orbit_class = 'GTO'              THEN 'GEO (Geosynchronous / transfer)'
            WHEN orbit_class LIKE 'HEO%'          THEN 'HEO (Highly Elliptical)'
            WHEN orbit_class IN ('ATM', 'SO', 'TA') THEN 'Low / Suborbital'
            WHEN orbit_class IN ('VHEO', 'DSO', 'CLO', 'EEO', 'HCO', 'PCO', 'SSE')
                                                  THEN 'Beyond GEO / Deep space'
            ELSE 'Other'
        END                                      AS orbit_family
    FROM {{ ref('gcat') }}
    WHERE orbit_class IS NOT NULL
      AND orbit_class != '-'
)

SELECT
    orbit_family,
    COUNT(*)                                     AS nb_objects,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
    , 1)                                         AS percent
FROM classified
GROUP BY orbit_family
ORDER BY nb_objects DESC
