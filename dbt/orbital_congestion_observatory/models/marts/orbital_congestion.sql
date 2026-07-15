WITH orbital_objects AS (

    SELECT *
    FROM {{ ref('orbital_objects') }}

),

leo_objects AS (

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

    FROM orbital_objects

    WHERE best_available_perigee_km < 2000

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
    COUNTIF(object_category = 'Component') AS component_count,

    ROUND(
    COUNTIF(object_category = 'Debris')
    * 100.0
    / COUNT(*),
    1
) AS debris_share_pct,

COUNTIF(object_category != 'Payload') AS non_payload_count,

ROUND(
    COUNTIF(object_category != 'Payload')
    * 100.0
    / COUNT(*),
    1
) AS non_payload_share_pct

FROM altitude_bands

GROUP BY altitude_band_km

ORDER BY object_count DESC
