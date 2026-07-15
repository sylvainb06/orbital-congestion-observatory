WITH objects AS (

    SELECT
        object_category,

        FLOOR(
            (
                best_available_perigee_km
                + best_available_apogee_km
            ) / 2 / 50
        ) * 50 AS altitude_band_km

    FROM {{ ref('orbital_objects') }}

)

SELECT
    altitude_band_km,
    object_category,
    COUNT(*) AS object_count

FROM objects

WHERE altitude_band_km IN (
    1150,
    1200,
    1400,
    1450
)

GROUP BY
    altitude_band_km,
    object_category

ORDER BY
    altitude_band_km,
    object_count DESC;
