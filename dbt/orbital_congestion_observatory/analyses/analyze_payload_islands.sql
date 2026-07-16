-- ============================================================
-- ANALYZE PAYLOAD-DOMINATED ISLANDS
-- ============================================================
-- Goal:
-- Investigate altitude ranges where payloads temporarily become
-- dominant inside broader debris-dominated orbital regions.
--
-- Two ranges were identified:
-- 1150-1200 km
-- 1400-1450 km
--
-- The goal is to determine whether these transitions are caused
-- by a decrease in debris or by a local concentration of payloads.
-- ============================================================

WITH island_objects AS (

    SELECT
        norad_cat_id,
        object_name,
        object_category,
        owner,
        state,
        launch_year,

        (
            best_available_perigee_km
            + best_available_apogee_km
        ) / 2 AS mean_altitude_km

    FROM {{ ref('orbital_objects') }}

),

classified_objects AS (

    SELECT
        *,

        FLOOR(mean_altitude_km / 50) * 50
            AS altitude_band_km

    FROM island_objects

    WHERE mean_altitude_km BETWEEN 1150 AND 1249.999
       OR mean_altitude_km BETWEEN 1400 AND 1499.999

)

SELECT
    altitude_band_km,
    object_category,
    owner,
    state,
    COUNT(*) AS object_count,
    MIN(launch_year) AS first_launch_year,
    MAX(launch_year) AS latest_launch_year

FROM classified_objects

GROUP BY
    altitude_band_km,
    object_category,
    owner,
    state

ORDER BY
    altitude_band_km,
    object_count DESC;
