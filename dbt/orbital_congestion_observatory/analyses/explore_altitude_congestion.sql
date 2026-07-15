-- ============================================================
-- EXPLORE ORBITAL CONGESTION BY ALTITUDE
-- ============================================================
-- Goal:
-- Explore how orbital objects are distributed across LEO altitude.
--
-- Mean orbital altitude is approximated as the average between
-- perigee and apogee.
--
-- Objects are grouped into 50 km altitude bands to reveal
-- concentration zones that would be hidden by broader orbital
-- classifications such as LEO, MEO or GEO.
--
-- This analysis revealed a major concentration around 450 km.
-- ============================================================

WITH leo_objects AS (

    SELECT
        norad_cat_id,
        object_name,
        object_category,
        status,
        best_available_perigee_km,
        best_available_apogee_km,

        (
            best_available_perigee_km
            + best_available_apogee_km
        ) / 2 AS mean_altitude_km

    FROM {{ ref('orbital_objects') }}

    WHERE orbital_zone IN (
        'LEO_CONTAINED',
        'LEO_CROSSING'
    )

),

altitude_bands AS (

    SELECT
        *,
        FLOOR(mean_altitude_km / 50) * 50 AS altitude_band_km

    FROM leo_objects

    WHERE mean_altitude_km BETWEEN 100 AND 2000

)

SELECT
    altitude_band_km,
    COUNT(*) AS object_count,

    COUNTIF(object_category = 'Payload') AS payload_count,
    COUNTIF(object_category = 'Debris') AS debris_count,
    COUNTIF(object_category = 'Rocket') AS rocket_count,
    COUNTIF(object_category = 'Component') AS component_count

FROM altitude_bands

GROUP BY altitude_band_km

ORDER BY object_count DESC;
