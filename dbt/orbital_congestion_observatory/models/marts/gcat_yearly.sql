-- =============================================================== --
-- MART GCAT - Yearly metrics (1 row = 1 launch year)
-- Groups every per-year KPI into a single table (same granularity)
--   - objects launched (all types)
--   - satellites launched (payloads only)
--   - launches (distinct launch tags)
--   - objects per launch (mega-constellation effect)
--   - total mass launched that year (kg)
--   - junk share that year
--   - cumulative objects / cumulative launches
--   - year-over-year growth rate of objects
--
-- READING WARNINGS:
--  * 2026 is a partial year (data pulled mid-2026). The last row is
--    incomplete: fewer objects, launches and mass than a full year.
--    Do notT read the 2026 drop as a real decline - exclude it or mark
--    it clearly on every time chart.
--  * junk_share_pct falls sharply in the mega-constellation era
--    (~75% in the 2000s down to a few % recently) because mass launches
--    of identical payloads dilute the debris share. But the absolute
--    number of junk objects still rises (e.g. 2022: 31.7% of 3582 =
--    1134 junk objects). Always show both the share (%) and the count.
--  * objects_per_launch spikes in the early 1960s come from early
--    fragmentations (one launch breaking into many debris), not from
--    multiple satellites per launch. The recent rise (~15-20 in 2022+)
--    is the real mega-constellation effect (many payloads per launch).
--  * total_mass_kg only sums objects with a known mass (> 0). Debris
--    and many components have no mass in GCAT, so this is a LOWER-BOUND
--    estimate of the real tonnage launched.
-- =============================================================== --

{{ config(materialized='table') }}

WITH yearly AS (
    SELECT
        launch_year,
        COUNT(*)                                        AS objects_launched,
        COUNTIF(category = 'Payload')                  AS satellites_launched,
        COUNT(DISTINCT launch_tag)                      AS launches,
        -- Total mass launched (only objects with a known positive mass)
        ROUND(SUM(IF(mass_kg > 0, mass_kg, 0)))         AS total_mass_kg
    FROM {{ ref('gcat') }}
    WHERE launch_year IS NOT NULL
    GROUP BY launch_year
)

SELECT
    launch_year,
    objects_launched,
    satellites_launched,
    launches,

    -- Mega-constellation effect: how many objects per launch
    -- (early-1960s highs = fragmentations; 2022+ highs = real payloads/launch)
    ROUND(objects_launched / NULLIF(launches, 0), 2)    AS objects_per_launch,

    -- Tonnage launched that year (lower bound, see header note)
    total_mass_kg,

    -- Junk = everything that is not a payload (rocket + component + debris).
    -- Keep both the count and the share (see header note on the paradox).
    objects_launched - satellites_launched              AS junk_objects,
    ROUND((objects_launched - satellites_launched) * 100.0
          / NULLIF(objects_launched, 0), 1)             AS junk_share_pct,

    -- Cumulative totals over time
    SUM(objects_launched) OVER (ORDER BY launch_year)   AS cumulative_objects,
    SUM(launches)         OVER (ORDER BY launch_year)   AS cumulative_launches,

    -- Year-over-year growth rate of objects (%)
    ROUND(
        (objects_launched - LAG(objects_launched) OVER (ORDER BY launch_year))
        * 100.0 / LAG(objects_launched) OVER (ORDER BY launch_year)
    , 1)                                                AS objects_growth_pct

FROM yearly
ORDER BY launch_year
