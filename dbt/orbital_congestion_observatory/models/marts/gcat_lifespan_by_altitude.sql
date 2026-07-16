-- =============================================================== --
-- MART GCAT - Lifespan by altitude band (1 row = 1 altitude band)
-- Shows how orbital altitude drives object lifespan: low orbits
-- decay fast (atmospheric drag), high orbits last for centuries.
-- Altitude is taken from perigee_km (the lowest point of the orbit,
-- the one that drives atmospheric decay).
--
-- READING WARNINGS:
--  * average_lifespan only covers objects that have re-entered.
--  * The trend is clean and physical up to ~2000 km: the higher the
--    orbit, the longer the lifespan (0-500 km ~5 yr, 500-1000 km ~15 yr,
--    1000-2000 km ~22 yr).
--  * BUT the GEO band (35000+ km) shows a lower average (~8-9 yr), which
--    looks like it breaks the trend. It does not: GEO objects almost
--    never re-enter, so the few that appear as re-entered are special
--    cases (deliberate disposal or odd data), a tiny biased sample. The
--    vast majority of GEO objects (still up there) are not counted, so
--    this average is not representative of real GEO lifespan. Do not
--    present the GEO figure as GEO objects live ~8 years.
--  * Negative perigees (escape / impact trajectories) are excluded by
--    the WHERE clause below.
-- =============================================================== --

{{ config(materialized='table') }}

WITH banded AS (
    SELECT
        CASE
            WHEN perigee_km <  500                   THEN '0-500 km (VLEO/LEO)'
            WHEN perigee_km <  1000                  THEN '500-1000 km (LEO)'
            WHEN perigee_km <  2000                  THEN '1000-2000 km (LEO high)'
            WHEN perigee_km <  35000                 THEN '2000-35000 km (MEO)'
            ELSE                                          '35000+ km (GEO and beyond)'
        END                                          AS altitude_band,
        decay_year,
        launch_year
    FROM {{ ref('gcat') }}
    WHERE perigee_km IS NOT NULL
      AND perigee_km >= 0
      AND launch_year IS NOT NULL
)

SELECT
    altitude_band,
    COUNT(*)                                          AS nb_objects,
    COUNTIF(decay_year IS NOT NULL)                   AS reentered_objects,
    ROUND(
        AVG(IF(decay_year IS NOT NULL, decay_year - launch_year, NULL))
    , 1)                                              AS average_lifespan_years
FROM banded
GROUP BY altitude_band
ORDER BY nb_objects DESC
