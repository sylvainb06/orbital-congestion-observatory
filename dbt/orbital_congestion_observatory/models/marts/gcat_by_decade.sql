-- =============================================================== --
-- MART GCAT - Metrics by decade (1 row = 1 launch decade)
-- Groups every per-decade KPI into a single table (same granularity)
--   - number of distinct launching countries (space democratisation)
--   - average lifespan of re-entered objects
--   - number of re-entered objects used for the lifespan average
--   - disposal quality: natural re-entry (R) vs active deorbit (D)
--
-- NOTE 1: average_lifespan only covers objects that have re-entered
-- (decay_year IS NOT NULL). Objects still in orbit are excluded, so
-- this figure under-estimates true lifespan (survivorship bias),
-- especially for recent decades.
--
-- NOTE 2: disposal codes come from McDowell's status scheme:
--   R = natural (uncontrolled) re-entry
--   D = active (controlled) deorbit
-- active_deorbit_pct = share of re-entries that were done on purpose,
-- a proxy for responsible end-of-life management over time.
-- =============================================================== --

{{ config(materialized='table') }}

SELECT
    CAST(FLOOR(launch_year / 10) * 10 AS INT64)         AS decade,

    -- Diversity of actors: how many distinct launching states/entities.
    -- NOTE: 'state' includes non-country codes (organisations like I-ESA),
    -- and treats SU (USSR) and RU (Russia) as separate, so this counts
    -- launching ENTITIES, not strictly sovereign countries.
    COUNT(DISTINCT state)                               AS distinct_launching_states,

    -- Lifespan of objects that have already re-entered
    COUNTIF(decay_year IS NOT NULL)                     AS reentered_objects,
    ROUND(
        AVG(IF(decay_year IS NOT NULL, decay_year - launch_year, NULL))
    , 1)                                                AS average_lifespan_years,

    -- Disposal quality: natural (R) vs active deorbit (D)
    COUNTIF(status = 'R')                               AS natural_reentries,
    COUNTIF(status = 'D')                               AS active_deorbits,
    ROUND(
        COUNTIF(status = 'D') * 100.0
        / NULLIF(COUNTIF(status IN ('R', 'D')), 0)
    , 1)                                                AS active_deorbit_pct

FROM {{ ref('gcat') }}
WHERE launch_year IS NOT NULL
GROUP BY decade
ORDER BY decade
