-- =============================================================== --
-- INTERMEDIATE — UCS satellites, analysis-ready (frozen 2023-05-01)
-- 1 row = 1 satellite, adds business flags on top of staging, grain unchanged
-- is_ghost: not registered with the UN registry ('NR' + dated variants)
-- =============================================================== --

SELECT
  *
  ,STARTS_WITH(registry_country, 'NR') AS is_ghost
  FROM {{ ref('ucs') }}
