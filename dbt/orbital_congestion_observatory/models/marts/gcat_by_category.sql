-- =============================================================== --
-- MART GCAT - Object breakdown by category
-- 1 row = 1 category (Payload / Rocket / Component / Debris / Other)
-- Shows count and share (%) of each category over the whole catalog.
-- Key insight: Debris + Rocket + Component = the Space Junk share,
-- vs Payload = the useful satellites share.
-- =============================================================== --

{{ config(materialized='table') }}

SELECT
    category,
    COUNT(*)                                            AS nb_objects,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
    , 2)                                                AS percent
FROM {{ ref('gcat') }}
GROUP BY category
ORDER BY nb_objects DESC
